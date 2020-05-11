function [Si_T1,Si_T2,Ti_T2,Al_T2,Fe_M1,Mg_M1,Vac_M1,Al_M2,Fe_M2,Mg_M2,K_A,Ca_A,Na_A,Vac_A,XMg,XFe,XAnn,XPhl,XSid,XEas,Xsum] = StructFctBiotite(Data,handles)
% -
% XMapTools External Function: Structural formula of biotite 
%
%   [outputs] = function_Name(Data,handles);
%
%   1>Biotite>Bio-StructForm>StructFctBiotite>Si_T1 Si_T2 Ti_T2 Al_T2 Fe_M1 
%     Mg_M1 Vac_M1 Al_M2 Fe_M2 Mg_M2 K_A Ca_A Na_A Vac_A XMg XFe XAnn XPhl 
%     XSid XEas Xsum>SiO2 TiO2 Al2O3 FeO MnO MgO CaO Na2O K2O>
%
%   End-member proportions are estimated based on biotite Al-content!
%
%   11 Oxygens
%
% 
% Created by P. Lanari (August 2011) - Last update 13/11/15.
% Find out more at http://www.xmaptools.com



Si_T1 = zeros(1,length(Data(:,1)));
Si_T2 = zeros(1,length(Data(:,1)));
Ti_T2 = zeros(1,length(Data(:,1)));
Al_T2 = zeros(1,length(Data(:,1)));
Fe_M1 = zeros(1,length(Data(:,1)));
Mg_M1 = zeros(1,length(Data(:,1)));
Vac_M1 = zeros(1,length(Data(:,1)));
Al_M2 = zeros(1,length(Data(:,1)));
Fe_M2 = zeros(1,length(Data(:,1)));
Mg_M2 = zeros(1,length(Data(:,1)));
K_A = zeros(1,length(Data(:,1)));
Ca_A = zeros(1,length(Data(:,1)));
Na_A = zeros(1,length(Data(:,1)));
Vac_A = zeros(1,length(Data(:,1)));
XMg = zeros(1,length(Data(:,1)));
XFe = zeros(1,length(Data(:,1)));
XAnn = zeros(1,length(Data(:,1)));
XPhl = zeros(1,length(Data(:,1)));
XSid = zeros(1,length(Data(:,1)));
XEas = zeros(1,length(Data(:,1)));
Xsum = zeros(1,length(Data(:,1)));



Fe3Per = 0;

XmapWaitBar(0,handles);
hCompt = 1;

NbOx = 11; % Oxygens, DO NOT CHANGE !!!

for i=1:length(Data(:,1)) % one by one
    
    hCompt = hCompt+1;
    if hCompt == 1000; % if < 150, the function is very slow.
        XmapWaitBar(i/length(Data(:,1)),handles);
        hCompt = 1;
    end
    
    Analyse = Data(i,:);

    if Analyse(1) > 0.001 % Biotite
        OnCal = 1;
    else
        OnCal = 0;
    end
    
    if OnCal
        TravMat= NaN*zeros(1,29); % Working matrix
    
        
        % From Garnet
        
        % SiO2 / TiO2 / Al2O3 / FeO / Fe2O3 / MnO / MgO / CaO / Na2O / K2O 
        Num = [1,1,2,1,2,1,1,1,2,2]; % Nombre de cations.
        NumO= [2,2,3,1,3,1,1,1,1,1]; % Nombre d'Oxyg??nes.
        Cst = [60.09,79.86,101.96,71.85,159.68,70.94,40.30,56.08, ...
            61.98,94.20]; % atomic mass

        TravMat(1:4) = Analyse(1:4); % Si02 TiO2 Al2O3 FeO
        TravMat(5) = 0; % Fe2O3
        TravMat(6:10) = Analyse(5:9); % MnO MgO CaO Na2O K2O
    
        for j=1:10
            TravMat(j+10) = TravMat(j) / Cst(j) * Num(j); % Atomic% = Oxyde/M.Molaire * Ncat
        end
    
        % adding Fe3+ 
        TravMat(14) = (1-(Fe3Per*0.01)) * Analyse(4) / Cst(4);
        TravMat(15) = Analyse(4) / Cst(4) - TravMat(14);
    
        TravMat(21) = sum((TravMat(11:20) .* NumO) ./ Num); % Oxygen sum
        TravMat(22) = TravMat(21) / NbOx; % ref Ox
    
        TravMat(23:32) = TravMat(11:20) ./ TravMat(22);

        % Association: 
        Si = TravMat(:,23);
        Ti = TravMat(:,24);
        Al= TravMat(:,25); 
        Fe= TravMat(:,26)+ TravMat(:,27);
        Mn= TravMat(:,28);
        Mg= TravMat(:,29);
        Ca= TravMat(:,30); 
        Na= TravMat(:,31); 
        K= TravMat(:,32);
        
        
%         % SiO2 / Al2O3 / FeO / Fe2O3 / MnO / MgO / CaO / Na2O / K2O 
%         Num = [1,2,1,2,1,1,1,2,2]; % Nombre de cations.
%         NumO= [2,3,1,3,1,1,1,1,1]; % Nombre d'Oxyg??nes.
%         Cst = [60.09,101.96,71.85,159.68,70.94,40.30,56.08, ...
%             61.98,94.20]; % atomic mass
% 
%         TravMat(1:3) = Analyse(1:3); % Si02 Al2O3 FeO
%         TravMat(4) = 0; % Fe2O3
%         TravMat(5:9) = Analyse(4:8); % MnO MgO CaO Na2O K2O
%     
%         for j=1:9
%             TravMat(j+9) = TravMat(j) / Cst(j) * Num(j); % Atomic% = Oxyde/M.Molaire * Ncat
%         end
%     
%         % adding Fe3+ 
%         TravMat(12) = (1-(Fe3Per*0.01)) * Analyse(3) / Cst(3);
%         TravMat(13) = Analyse(3) / Cst(3) - TravMat(12);
%     
%         TravMat(19) = sum((TravMat(10:18) .* NumO) ./ Num); % Oxygen sum
%         TravMat(20) = TravMat(19) / NbOx; % ref Ox
%     
%         TravMat(21:29) = TravMat(10:18) ./ TravMat(20);
% 
%         % Association: 
%         Si = TravMat(:,21);
%         Al= TravMat(:,22); 
%         Fe= TravMat(:,23)+ TravMat(:,24);
%         Mn= TravMat(:,25);
%         Mg= TravMat(:,26);
%         Ca= TravMat(:,27); 
%         Na= TravMat(:,28); 
%         K= TravMat(:,29);

        % Structural Formula (August 2013)
        XMg(i) = Mg/(Mg+Fe);
        XFe(i) = 1-XMg(i);
        
        Si_T1(i) = 2;
        Si_T2(i) = Si-Si_T1(i);
        
        Ti_T2(i) = Ti;
        
        Al_T2_theo = 2-(Si_T2(i) + Ti_T2(i));   % This is the amount free in T2 for Al
        
        if Al_T2_theo > Al
            Al_T2(i) = Al;         % we have not enough Al !!!
        else
            Al_T2(i) = Al_T2_theo;
        end
        
        % M2 (including siderophyllite and eastonite EM):
        Alvi = Al-Al_T2(i);
        
        Al_M2(i) = Alvi;
        FeMg_M2 = 2 - Al_M2(i);
        
        Fe_M2(i) = FeMg_M2*(1-XMg(i));
        Mg_M2(i) = FeMg_M2*XMg(i);
        
        
        % M1 (including vacancy):        
        FeMg_M1 = (Fe + Mg) - FeMg_M2;
        
        if FeMg_M1 < 1
            Vac_M1(i) = 1-FeMg_M1;
        else
            Vac_M1(i) = 0;            % we have to much Mg+Fe !!!
        end
        
        Fe_M1(i) = FeMg_M1*(1-XMg(i));
        Mg_M1(i) = FeMg_M1*XMg(i);
        
        % A
        K_A(i) = K;
        Ca_A(i) = Ca;
        Na_A(i) = Na;
        
        if K+Ca+Na <= 1;
            Vac_A(i) = 1-(K+Ca+Na);
        else
            Vac_A(i) = 0;            % to high interfoliar sum !!!
        end
        
        % New structural formula PL - 13.11.2015
        
        XSidEast = Al-1;
        XPhlAnn = 2-Al;
        
        XAnn(i) = XPhlAnn * XFe(i);
        XPhl(i) = XPhlAnn * XMg(i);
        XSid(i) = XSidEast * XFe(i);
        XEas(i) = XSidEast * XMg(i);
        
        Xsum(i) = XAnn(i)+XPhl(i)+XSid(i)+XEas(i);
        
        
        if Si > 3.2 || Si < 2 || K > 1.1
            Si_T1(i) = 0;
            Si_T2(i) = 0;
            Ti_T2(i) = 0;
            Al_T2(i) = 0;
            Fe_M1(i) = 0;
            Mg_M1(i) = 0;
            Vac_M1(i) = 0;
            Al_M2(i) = 0;
            Fe_M2(i) = 0;
            Mg_M2(i) = 0;
            K_A(i) = 0;
            Ca_A(i) = 0;
            Na_A(i) = 0;
            Vac_A(i) = 0;
            XMg(i) = 0;
            XFe(i) = 0;
            XAnn(i) = 0;
            XPhl(i) = 0;
            XSid(i) = 0;
            XEas(i) = 0;
            Xsum(i) = 0;    
            
        end
        
        
    else
        Si_T1(i) = 0;
        Si_T2(i) = 0;
        Ti_T2(i) = 0;
        Al_T2(i) = 0;
        Fe_M1(i) = 0;
        Mg_M1(i) = 0;
        Vac_M1(i) = 0;
        Al_M2(i) = 0;
        Fe_M2(i) = 0;
        Mg_M2(i) = 0;
        K_A(i) = 0;
        Ca_A(i) = 0;
        Na_A(i) = 0;
        Vac_A(i) = 0;
        XMg(i) = 0;
        XFe(i) = 0;
        XAnn(i) = 0;
        XPhl(i) = 0;
        XSid(i) = 0;
        XEas(i) = 0;
        Xsum(i) = 0;
    end
        
end

XmapWaitBar(1,handles);
return






