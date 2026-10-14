function [i1, i2, converged] = solve_ebers_moll_npn(v1, v2)

    Vt = 25.85e-3;
    alpha_f = 0.9890;
    alpha_r = 0.8333;
    Rs1 = 1e-5;
    Rs2 = 1e-5;
    Rp1 = 1e5;
    Rp2 = 1e5;
    eta_f = 1.5;
    eta_r = 2.0;
    Is1 = 5e-6;
    Is2 = 5e-6;

    % Initial guess
    exp1 = safe_exp(v1/(eta_f*Vt));
    exp2 = safe_exp(v2/(eta_r*Vt));

    i1 = -Is1*(exp1 - 1) + alpha_r*Is2*(exp2 - 1);
    i2 = -Is2*(exp2 - 1) + alpha_f*Is1*(exp1 - 1);

    converged = false;

    for iter = 1:100

        [f1, f2] = residuals( ...
            i1, i2, v1, v2, ...
            Is1, Is2, alpha_f, alpha_r, ...
            Rs1, Rs2, Rp1, Rp2, eta_f, eta_r, Vt);

        v_j1 = v1 + i1*Rs1;
        v_j2 = v2 + i2*Rs2;

        exp1 = safe_exp(v_j1/(eta_f*Vt));
        exp2 = safe_exp(v_j2/(eta_r*Vt));

        df1_di1 = 1 + (Rs1/(eta_f*Vt))*Is1*exp1 + Rs1/Rp1;
        df1_di2 = -alpha_r*(Rs2/(eta_r*Vt))*Is2*exp2;

        df2_di1 = -alpha_f*(Rs1/(eta_f*Vt))*Is1*exp1;
        df2_di2 = 1 + (Rs2/(eta_r*Vt))*Is2*exp2 + Rs2/Rp2;

        J = [df1_di1, df1_di2;
             df2_di1, df2_di2];

        f = [f1(:); f2(:)];

        if any(~isfinite(f)) || any(~isfinite(J(:)))
            warning('Nonfinite residual or Jacobian at v1=%g, v2=%g.', v1, v2);
            return
        end

        step = -J\f;

        % Backtracking line search
        alpha = 1;
        norm_f_old = norm(f);

        for k = 1:40
            i1_trial = i1 + alpha*step(1);
            i2_trial = i2 + alpha*step(2);

            [f1_trial, f2_trial] = residuals( ...
                i1_trial, i2_trial, v1, v2, ...
                Is1, Is2, alpha_f, alpha_r, ...
                Rs1, Rs2, Rp1, Rp2, eta_f, eta_r, Vt);

            f_trial = [f1_trial(:); f2_trial(:)];

            if all(isfinite(f_trial)) && ...
                    norm(f_trial) < (1 - 1e-4*alpha)*norm_f_old
                break
            end

            alpha = alpha/2;
        end

        i1 = i1_trial;
        i2 = i2_trial;

        if norm(f_trial) < 1e-9 && ...
                max(abs(step)) < 1e-12
            converged = true;
            return
        end
    end
end

function [f1, f2] = residuals( ...
    i1, i2, v1, v2, ...
    Is1, Is2, alpha_f, alpha_r, ...
    Rs1, Rs2, Rp1, Rp2, eta_f, eta_r, Vt)

    v_j1 = v1 + i1*Rs1;
    v_j2 = v2 + i2*Rs2;

    exp1 = safe_exp(v_j1/(eta_f*Vt));
    exp2 = safe_exp(v_j2/(eta_r*Vt));

    f1 = i1 - (-Is1*(exp1 - 1) + ...
          alpha_r*Is2*(exp2 - 1) - ...
          v_j1/Rp1);

    f2 = i2 - (-Is2*(exp2 - 1) + ...
          alpha_f*Is1*(exp1 - 1) - ...
          v_j2/Rp2);
end

function y = safe_exp(x)

    x_max = 700;
    x_min = -700;

    y = zeros(size(x));

    normal = (x >= x_min) & (x <= x_max);
    y(normal) = exp(x(normal));

    y(x > x_max) = exp(x_max) .* (1 + x(x > x_max) - x_max);
    y(x < x_min) = exp(x_min) .* (1 + x(x < x_min) - x_min);
end