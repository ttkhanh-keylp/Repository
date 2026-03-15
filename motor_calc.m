function result = motor_calc(HP,VL,Eff,PF,f,P,N,K,L,R,X,PF_target)

%% 1. Rated Power (kW)

Pdm = HP * 0.746;

%% 2. Rated Current

Idm = Pdm*1000/(sqrt(3)*VL*Eff*PF);

%% 3. Phase Current

IP = Idm/sqrt(3);

%% 4. Synchronous Speed

Ns = 120*f/P;

%% 5. Slip

slip = (Ns - N)/Ns;

slip_percent = slip*100;

%% 6. Input Power

Pin = Pdm/Eff;

%% 7. Power Loss

Ploss = Pin - Pdm;

%% 8. Corrected Current

Idm_corr = Idm * K;

%% 9. Torque

T_sync = 9550*Pdm/Ns;

T_load = 9550*Pdm/N;

%% 10. Voltage Drop

cosphi = PF;

sinphi = sqrt(1 - cosphi^2);

Z = R*cosphi + X*sinphi;

VoltageDrop = sqrt(3)*Idm*(Z)*(L/1000);

VoltageDrop_percent = VoltageDrop/VL*100;

%% 11. Reactive Power Compensation

phi1 = acos(PF);

phi2 = acos(PF_target);

Qc = Pdm*(tan(phi1) - tan(phi2));

%% SAVE RESULT

result.Pdm = Pdm;
result.Idm = Idm;
result.IP = IP;
result.Ns = Ns;

result.slip = slip;
result.slip_percent = slip_percent;

result.Pin = Pin;
result.Ploss = Ploss;

result.Idm_corr = Idm_corr;

result.T_sync = T_sync;
result.T_load = T_load;

result.VoltageDrop = VoltageDrop;
result.VoltageDrop_percent = VoltageDrop_percent;

result.Qc = Qc;

end