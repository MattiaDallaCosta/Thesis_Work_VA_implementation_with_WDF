function [i1, i2] = solve_ebers_moll_npn(v1, v2)
    Vt = 25.85e-3;
    alpha_f = 0.9993;
    alpha_r = 0.5579;
    Rs1 = 10e-5; Rs2 = 10e-5;
    Rp1 = 10e11;  Rp2 = 10e8;
    eta_f = 1;  eta_r = 1;
    Is1 = 5.9151e-15;  Is2 = 10.595e-15;

    % 1. Initial Guess (Signs inverted for NPN entering currents)
    i1 = Is1 * (exp(v1 / (eta_f * Vt)) - 1) - alpha_r * Is2 * (exp(v2 / (eta_r * Vt)) - 1);
    i2 = Is2 * (exp(v2 / (eta_r * Vt)) - 1) - alpha_f * Is1 * (exp(v1 / (eta_f * Vt)) - 1);

    for iter = 1:50 
        % 2. Pre-calculate exponentials (Signs flipped: internal voltage drops add to terminal voltage)
        x1 = (v1 - i1.*Rs1) / (eta_f * Vt);
        x2 = (v2 - i2.*Rs2) / (eta_r * Vt);

        exp1 = exp(x1); %some NaN
        exp2 = exp(x2); %some NaN

        % fprintf( 'iter=%d, x1=%.6g, x2=%.6g, exp1=%.6g, exp2=%.6g\n', iter, x1, x2, exp1, exp2);

        % 3. Residuals (Ebers-Moll physics terms negated)
        f1 = i1 - (Is1.*(exp1 - 1) - alpha_r.*Is2.*(exp2 - 1) - (v1 - i1.*Rs1)/Rp1);
        f2 = i2 - (Is2.*(exp2 - 1) - alpha_f.*Is1.*(exp1 - 1) - (v2 - i2.*Rs2)/Rp2);

        % 4. Jacobian components (Corrected mathematical bugs from original code)
        df1_di1 = 1 + (Rs1/(eta_f*Vt) * Is1 .* exp1) + Rs1/Rp1; % some NaN
        df1_di2 = - alpha_r * (Rs2/(eta_r*Vt) * Is2 .* exp2); % some NaN
        df2_di1 = - alpha_f * (Rs1/(eta_f*Vt) * Is1 .* exp1); % some NaN
        df2_di2 = 1 + (Rs2/(eta_r*Vt) * Is2 .* exp2) + Rs2/Rp2; % some NaN

        detJ = df1_di1 .* df2_di2 - df1_di2 .* df2_di1;

        % Calculate the Newton step
        di1 = (-df2_di2 .* f1 + df1_di2 .* f2) ./ detJ;
        di2 = (df2_di1 .* f1 - df1_di1 .* f2) ./ detJ;

        % Apply the update
        i1 = i1 + di1;
        i2 = i2 + di2;

        % Vector-safe early convergence check
        max_step = max(max(abs(di1), [], 'all'), max(abs(di2), [], 'all'));
        max_res  = max(max(abs(f1), [], 'all'), max(abs(f2), [], 'all'));

        if max_step < 1e-12 && max_res < 1e-7
            break;
        end
    end
end

