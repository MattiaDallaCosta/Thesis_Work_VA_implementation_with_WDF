function [i1, i2] = solve_ebers_moll(v1, v2)
% Extended Ebers-Moll BJT model as a two-port
% Ports are defined so both junctions are forward biased for v > 0:
%   npn: v1 = vBE, v2 = vBC  ->  i1 = iBE, i2 = iBC
%   pnp: v1 = vEB, v2 = vCB  ->  i1 = iEB, i2 = iCB

    % Parameters: 2N5089 (Big Muff Pi input stage), DAFx23 Table 1
    Vt = 25.85e-3;
    alpha_f = 0.9993;
    alpha_r = 0.5579;
    Rs1 = 1e-5; Rs2 = 1e-5;
    Rp1 = 1e11;  Rp2 = 1e8;
    eta_f = 1;  eta_r = 1;
    Is1 = 5.9151e-15;  Is2 = 10.595e-15;

    % Initial guess (exact solution for Rs = 0)
    i1 = Is1 * (exp(v1 / (eta_f * Vt)) - 1) - alpha_r * Is2 * (exp(v2 / (eta_r * Vt)) - 1) + v1 / Rp1;
    i2 = Is2 * (exp(v2 / (eta_r * Vt)) - 1) - alpha_f * Is1 * (exp(v1 / (eta_f * Vt)) - 1) + v2 / Rp2;

    for iter = 1:50
        % Pre-calculate exponentials
        exp1 = exp((v1 - i1.*Rs1) / (eta_f * Vt));
        exp2 = exp((v2 - i2.*Rs2) / (eta_r * Vt));

        f1 = i1 - (Is1*(exp1 - 1) - alpha_r*Is2*(exp2 - 1) + (v1 - i1.*Rs1)/Rp1);
        f2 = i2 - (Is2*(exp2 - 1) - alpha_f*Is1*(exp1 - 1) + (v2 - i2.*Rs2)/Rp2);

        % Jacobian components
        df1_di1 = 1 + Rs1 * (Is1 * exp1 / (eta_f*Vt) + 1/Rp1);
        df1_di2 =   - alpha_r * Rs2 * Is2 * exp2 / (eta_r*Vt);
        df2_di1 =   - alpha_f * Rs1 * Is1 * exp1 / (eta_f*Vt);
        df2_di2 = 1 + Rs2 * (Is2 * exp2 / (eta_r*Vt) + 1/Rp2);

        detJ = df1_di1 .* df2_di2 - df1_di2 .* df2_di1;

        % Newton step
        di1 = (-df2_di2 .* f1 + df1_di2 .* f2) ./ detJ;
        di2 = ( df2_di1 .* f1 - df1_di1 .* f2) ./ detJ;

        i1 = i1 + di1;
        i2 = i2 + di2;

        % Convergence check
        max_step = max(max(abs(di1), [], 'all'), max(abs(di2), [], 'all'));
        max_res  = max(max(abs(f1),  [], 'all'), max(abs(f2),  [], 'all'));

        if max_step < 1e-12 && max_res < 1e-7
            break;
        end
    end
end
