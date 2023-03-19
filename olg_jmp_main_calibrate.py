import numpy as np
import pandas as pd
from scipy.optimize import least_squares
import time

# Nishaad Rao

# First, we calibrate the initial equilibrium. Next, we update wages
# (really, we are setting productivity to justify wages in the final
# equilibrium, but effectively this means we update wages) and calculate
# the new equilibrium.
start_time = time.time()

initial = pd.read_csv('params_dist_1999.csv')

# Consumer Parameters  -- common across areas
alpha = 2 / 3  # Income share of consumption
beta = 0.96  # Determines how much household cares about next generation.
sigma = 2.2
gamma = 1.1  # Risk Aversion for bequests
delta = 0.05
z = 1  # Normalization parameter

kappa = [-1.2, -0.6, -0.3, -0.1, 0.1, 0.4, 0.6, 0.8, 1, 1.2]  # kappa that replicates national level homeownership % by income deciles.

# Define grids that contain parameters for each area:
J, col = initial.shape  # Number of areas
Lab_Ptiles = 10
par_h = 0.5 * np.ones(10)  # set to match elasticity of homeownership with respect to income in PSID
par_m = np.ones(10)  # set to match migration elasticity in Hornbeck and Moretti

I = 2
shares_tenure = np.zeros((J, Lab_Ptiles * I))
shares_own = np.zeros(Lab_Ptiles)
shares_rent = np.zeros(Lab_Ptiles)
pop_tenure = np.zeros((J, Lab_Ptiles * I))
pop_own = np.zeros(Lab_Ptiles)
pop_rent = np.zeros(Lab_Ptiles)

shares_pop = np.zeros((J, I * Lab_Ptiles))
q = np.zeros((J, 1))
p_h = np.zeros((J, 1))
cstar = np.zeros((J, Lab_Ptiles * I))
hstar = np.zeros((J, Lab_Ptiles * I))
astar = np.zeros((J, Lab_Ptiles * I))
wealth = np.zeros((J, Lab_Ptiles * I))
house = np.zeros((J, Lab_Ptiles * I))
u = np.zeros((J, Lab_Ptiles * I))

eta = initial.iloc[:, 11].values
fhfa = initial.iloc[:, 12].values
D = np.zeros((J, 1))
w = initial.iloc[:, 1:11].values  # Wages

mu = 1 / 3  # Capital Share -- common across areas
rho = 1 / 2
nu = rho / (rho - 1)
w = w / 11  # Normalization of wages, scale doesn't really matter economically, but it keeps the asset values solvable.

L0 = initial.iloc[:, 14].values  # Employment
L0 = L0 * 0.05
L0 = np.repeat(L0[:, np.newaxis], 20, axis=1)

L0_theta = np.zeros((J, Lab_Ptiles))

for l in range(Lab_Ptiles):
    L0_theta[:, l] = L0[:, l * I - 1] + L0[:, l * I]

params_rent = np.zeros((J, 8))
params_own = np.zeros((J, 9))

maxit_D = 50
tol_D = 1e-2
err = np.zeros(maxit_D)

maxit_L = 10
L = L0
L_target = np.sum(L, axis=1)
tol_L = 1e-3
error_L = np.zeros(maxit_L)

p_h = fhfa

r = 0.03
R = 1 + r


for n in range(maxit_L):

    L_theta = np.zeros((J, Lab_Ptiles))

    for l in range(Lab_Ptiles):
        L_theta[:, l] = L[:, l * I - 1] + L[:, l * I]

    for j in range(J):  # Area-wide loop

        # Initializing iterations:
        HD = np.zeros((J, 1))

        # General Equilibrium: Need to determine rental rate of housing, i.e., r_h
        # We will iterate on this.
        q[j] = (r + delta) * p_h[j]

        for l in range(Lab_Ptiles):

            x0 = [1, 1, 1]
            lb = [0, 0, 0]
            ub = [10, 25, 100]

            # Solve renter's problem:
            params_rent[j, :] = [alpha, beta, sigma, gamma, w[j, l], q[j], z, R]

            myfun = lambda x: hhsolve_renter(x, params_rent[j, :])
            result = least_squares(myfun, x0, bounds=(lb, ub))
            x = result.x

            cstar[j, l * I - 1] = x[0]
            hstar[j, l * I - 1] = x[1]
            astar[j, l * I - 1] = x[2]

            # Solve owner's problem:
            params_own[j, :] = [alpha, beta, sigma, gamma, delta, w[j, l], p_h[j], z, R]

            myfun = lambda x: hhsolve_owner(x, params_own[j, :])
            result = least_squares(myfun, x0, bounds=(lb, ub))
            x = result.x

            cstar[j, l * I] = x[0]
            hstar[j, l * I] = x[1]
            astar[j, l * I] = x[2]

        for l in range(Lab_Ptiles):
            wealth[j, l * I - 1] = astar[j, l * I - 1]
            wealth[j, l * I] = (astar[j, l * I] + p_h[j] * hstar[j, l * I])

            house[j, l * I - 1] = 0
            house[j, l * I] = p_h[j] * hstar[j, l * I]

        u[j, :] = (((cstar[j, :]**alpha) * (hstar[j, :]**(1-alpha)) / z)**(1-sigma)) / (1-sigma) + \
                  beta * ((wealth[j, :] / z)**(1-gamma)) / (1-gamma)

        for l in range(Lab_Ptiles):
            shares_own[0, l] = (np.exp(u[j, l * I] + kappa[l])**(1 / par_h[l])) / \
                               ((np.exp(u[j, l * I] + kappa[l]))**(1 / par_h[l]) + (np.exp(u[j, l * I - 1]))**(1 / par_h[l]))
            shares_rent[0, l] = 1 - shares_own[0, l]
            pop_own[0, l] = L_theta[j, l] * shares_own[0, l]  # Population that owns
            pop_rent[0, l] = L_theta[j, l] * shares_rent[0, l]  # Population that rents

        for l in range(Lab_Ptiles):
            shares_tenure[j, l * I - 1] = shares_rent[0, l]
            shares_tenure[j, l * I] = shares_own[0, l]
            pop_tenure[j, l * I - 1] = pop_rent[0, l]
            pop_tenure[j, l * I] = pop_own[0, l]

        HD[j] = np.sum(pop_tenure[j, :] * hstar[j, :])  # Housing Demanded
        D[j] = HD[j] / (p_h[j] ** eta[j])

    # End area-wide loop
maxit_nu = 40
K_S = np.zeros(maxit_nu)
K_D = np.zeros(maxit_nu)
ES_K = np.zeros(maxit_nu)
tol_nu = 1e-2
numin = 0.2
numax = 4
nu = 1

for b in range(maxit_nu):

    K = ((w / R) * (mu / (1 - mu)) ** nu) * L_theta
    theta = w / ((1 - mu) * (K ** mu) * (L_theta ** (-mu)))

    K_D[b] = np.sum(K)
    K_S[b] = np.sum(astar * pop_tenure)

    ES_K[b] = K_S[b] - K_D[b]

    if ES_K[b] > tol_nu:
        numin = nu
        nu = (numax + nu) / 2

    elif ES_K[b] < -tol_nu:
        numax = nu
        nu = (numin + nu) / 2

    elif abs(ES_K[b]) <= tol_nu:
        print("Equilibrium nu found")
        break

# Calculate population shares implied by the initial equilibrium:
if n <= 2:
    v_h = np.zeros((J, Lab_Ptiles))

    Aj = np.zeros(J)
    for j in range(J):
        Aj[j] = 0.9 * L_target[j] ** 2 + 2 * L_target[j]

    maxit_L = 100
    L_err = np.zeros((J, maxit_L))
    L_err_max = np.zeros(maxit_L)
    Amin = 0.01
    Amax = 20

    for m in range(maxit_L):
        for j in range(J):
            for l in range(Lab_Ptiles):
                v_h[j, l] = par_h[l] * np.log(
                    np.exp(u[j, l * I - 1] + Aj[j]) ** (1 / par_h[l]) + np.exp(u[j, l * I] + kappa[l] + Aj[j]) ** (
                        1 / par_h[l]))

        e_v_h = np.zeros((J, Lab_Ptiles))
        for l in range(Lab_Ptiles):
            e_v_h[:, l] = np.exp(v_h[:, l]) ** (1 / par_m[l])

        sum_e_v_h = np.sum(e_v_h)

        for l in range(Lab_Ptiles):
            shares_pop[:, l * I - 1] = (1 / Lab_Ptiles) * (e_v_h[:, l] / sum_e_v_h[l]) * shares_tenure[:, l * I - 1]
            shares_pop[:, l * I] = (1 / Lab_Ptiles) * (e_v_h[:, l] / sum_e_v_h[l]) * shares_tenure[:, l * I]

        L_update = 100 * shares_pop

        L_current = np.sum(L_update, axis=1)

        L_err[:, m] = L_current - L_target

        L_err_max[m] = np.max(np.abs(L_err[:, m]))


        if np.abs(L_err_max[m]) > tol_L:
            for j in range(J):
                if 0 <= j <= 98:
                    if L_err[j, m] > tol_L:
                        Aj[j] = 0.95 * Aj[j] + 0.05 * Amin
                    elif L_err[j, m] < -tol_L:
                        Aj[j] = 0.95 * Aj[j] + 0.05 * Amax
                    elif np.abs(L_err[j, m]) <= tol_L:
                        Aj[j] = Aj[j]
                elif j > 98:
                    if L_err[j, m] > tol_L:
                        Aj[j] = 0.93 * Aj[j] + 0.07 * Amin
                    elif L_err[j, m] < -tol_L:
                        Aj[j] = 0.93 * Aj[j] + 0.07 * Amax
                    elif np.abs(L_err[j, m]) <= tol_L:
                        Aj[j] = Aj[j]
        elif np.abs(L_err_max[m]) <= tol_L:
            print(f"Equilibrium Population found on iteration {n}.")
            break

    L = L_update

if n > 2:

    for j in range(J):
        for l in range(Lab_Ptiles):
            v_h[j, l] = par_h[l] * np.log(
                np.exp(u[j, l * I - 1] + Aj[j]) ** (1 / par_h[l]) + np.exp(u[j, l * I] + kappa[l] + Aj[j]) ** (
                    1 / par_h[l]))

    e_v_h = np.zeros((J, Lab_Ptiles))
    for l in range(Lab_Ptiles):
        e_v_h[:, l] = np.exp(v_h[:, l]) ** (1 / par_m[l])

    sum_e_v_h = np.sum(e_v_h)

    for l in range(Lab_Ptiles):
        shares_pop[:, l * I - 1] = (1 / Lab_Ptiles) * (e_v_h[:, l] / sum_e_v_h[l]) * shares_tenure[:, l * I - 1]
        shares_pop[:, l * I] = (1 / Lab_Ptiles) * (e_v_h[:, l] / sum_e_v_h[l]) * shares_tenure[:, l * I]

    L_update = 100 * shares_pop

    error_L[n] = np.max(np.abs(L - L_update))

    if error_L[n] > tol_L:
        L = L_update
        print(f"Did not converge. Error = {error_L[n]}.")
    elif error_L[n] <= tol_L:
        print(f"Equilibrium Population Dist. found on iteration {n}.")
        break

p_h_initial = p_h.copy()
q_initial = q.copy()
wealth_initial = wealth.copy()
astar_initial = astar.copy()
cstar_initial = cstar.copy()
hstar_initial = hstar.copy()
u_initial = u.copy()
fhfa_initial = fhfa.copy()
zhvi_initial = np.array(initial[:, 13])  # Assuming 'initial' is a numpy array
house_initial = house.copy()
L_initial = L_update.copy()
shares_initial = shares_pop.copy()
theta_initial = theta.copy()
w_initial = w.copy()
L_area = np.sum(L_initial, axis=1)

end_time = time.time()
elapsed_time = end_time - start_time
print(f"Elapsed time: {elapsed_time:.2f} seconds")
