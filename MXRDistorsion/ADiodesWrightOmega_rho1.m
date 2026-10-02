function [b, r] = ADiodesWrightOmega_rho1(a, Z)
    
    Vt = 25.85e-3; % Thermal Voltage of 1N4148
    Is = 4.352e-9; % Saturation current of 1N4148
    eta = 1.905; % ideality factor of 1N4148
    Rs = 0.001; % series resistance of extended Diode
    Rp = 100000000; % parallel resistance of extended Diode
    
    mod_a = abs(a);
    sign_a = sign(a);
      
    alpha = 1 - Rs/Z;
    beta = 1 + Rs/Z;
    delta = 1/Z;

    aa = beta/(2*eta*Vt);
    bb = mod_a*alpha/(2*eta*Vt);
    cc = (-0.5*(beta/Rp) - 0.5*(delta))/Is;
    dd = (mod_a*(0.5*delta - 0.5*(alpha/Rp))/Is) + 1;

    arg = bb - aa*(dd/cc) + log(-(aa/cc));
    expArg = exp(arg);

    if expArg==inf
        b = sign_a*(-(dd/cc) - OmegaWrightDangelo(arg,4)/aa);
    else
        b = sign_a*(-(dd/cc) - Lambert_W_Fritsch(expArg)/aa);
    end
    
    v = (a+b)/2;
    i = (a-b)/(2*Z);

    
    r = (((2*Is*Rs)/(eta*Vt))*cosh((v-i*Rs)/(eta*Vt)) + (Rs/Rp) + 1)/((2*Is/(eta*Vt))*cosh((v-i*Rs)/(eta*Vt)) + 1/Rp);
end


