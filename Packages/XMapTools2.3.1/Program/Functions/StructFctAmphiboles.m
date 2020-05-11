function [Si4,Aliv,Alvi,Al_T2,Al_M2,XFe,XMg,Mg_M2,Fe_M2,Fe_M13,Mg_M13,Ca_M4,Na_M4,Na_A,V_A,Xtr,Xftr,Xts,Xparg,Xgl] = StructFctAmphiboles(Data,handles)
% -
% XMapTools External Function: Structural formula of Ca-amphibole 
%
%   [outputs] = function_Name(Data,handles);
%
%   1>Amphibole>Amp-StrucForm>StructFctAmphiboles>Si4 Aliv Alvi Al_T2 Al_M2 
%     XFe XMg Mg_M2 Fe_M2 Fe_M13 Mg_M13 Ca_M4 V_M4 Na_A V_A Xtr Xftr Xts 
%     Xparg Xgl>SiO2 TiO2 Al2O3 FeO MnO MgO CaO Na2O K2O>
%
%   23 Oxygens
%
% 
% Created by P. Lanari (Octobre 2011) - Last update 28/10/11.
% Find out more at http://www.xmaptools.com



Si4 = zeros(1,length(Data(:,1)));
Aliv = zeros(1,length(Data(:,1)));
Alvi = zeros(1,length(Data(:,1)));
Al_T2 = zeros(1,length(Data(:,1)));
Al_M2 = zeros(1,length(Data(:,1)));
XFe = zeros(1,length(Data(:,1)));
XMg = zeros(1,length(Data(:,1))); 
Mg_M2 = zeros(1,length(Data(:,1)));
Fe_M2 = zeros(1,length(Data(:,1)));
Fe_M13 = zeros(1,length(Data(:,1)));
Mg_M13 = zeros(1,length(Data(:,1)));
Ca_M4 = zeros(1,length(Data(:,1)));
Na_M4 = zeros(1,length(Data(:,1)));
Na_A = zeros(1,length(Data(:,1)));
V_A = zeros(1,length(Data(:,1)));
Xtr = zeros(1,length(Data(:,1)));
Xftr = zeros(1,length(Data(:,1)));
Xts = zeros(1,length(Data(:,1)));
Xparg = zeros(1,length(Data(:,1))); 
Xgl = zeros(1,length(Data(:,1))); 


XmapWaitBar(0,handles);
hCompt = 1;
NbOx = 23; % Oxygens, DO NOT CHANGE !!!


% SiO2 / TIO2 / Al2O3 / FeO / Fe2O3 / MnO / MgO / CaO / Na2O / K2O 
Num = [1,1,2,1,2,1,1,1,2,2]; % Nombre de cations.
NumO= [2,2,3,1,3,1,1,1,1,1]; % Nombre d'Oxygenes.
Cst = [60.09,79.88,101.96,71.85,159.68,70.94,40.30,56.08, ...
    61.98,94.20]; % atomic mass


for i=1:length(Data(:,1)) % one by one
    
    hCompt = hCompt+1;
    if hCompt == 1000; % if < 150, the function is very slow.
        XmapWaitBar(i/length(Data(:,1)),handles);
        hCompt = 1;
    end
    
    Analyse = Data(i,:);
    
    if Analyse(1) > 0.0001 % detection...
        OnCal = 1;
    else
        OnCal = 0;
    end

    TravMat = []; % initialization required... 

    if OnCal
        TravMat(1:4) = Analyse(1:4); % Si02 TiO2 Al2O3 FeO
        TravMat(5) = 0; % Fe2O3
        TravMat(6:10) = Analyse(5:9); % MnO MgO CaO Na2O K2O

        AtomicPer = TravMat./Cst.*Num;

        TheSum = sum((AtomicPer .* NumO) ./ Num);
        RefOx = TheSum/NbOx;

        lesResults = AtomicPer / RefOx;

        Si = lesResults(1);
        Ti = lesResults(2);
        Al = lesResults(3); 
        Fe = lesResults(4)+ lesResults(5);
        Mn = lesResults(6);
        Mg = lesResults(7);
        Ca = lesResults(8); 
        Na = lesResults(9); 
        K = lesResults(10);


        % Structural Formulae (P. Lanari - 2011)
        
   
        Si4(i) = Si;
        Aliv(i) = 4 - (Si+Ti - 4);    % +Ti ???
        Alvi(i) = Al - Aliv(i);
        Al_T2(i) = Aliv(i);
        Al_M2(i) = Alvi(i);
        
        XFe(i) = Fe/(Fe+Mg+Mn);      % +Mn ???
        XMg(i) = Mg/(Fe+Mg+Mn);       % +Mn ???
        
        FeMg_M2 = 2 - Al_M2(i);
        FeMg_M13 = (Fe+Mg) - FeMg_M2;
        
        Mg_M2(i) = FeMg_M2 * XMg(i);
        Fe_M2(i) = FeMg_M2 * XFe(i);
        
        Mg_M13(i) = FeMg_M13 * XMg(i);
        Fe_M13(i) = FeMg_M13 * XFe(i);
        
        Ca_M4(i) = Ca;
        Na_M4(i) = 2 - Ca_M4(i);
        Na_A(i) = Na - Na_M4(i);
        V_A(i) = 1-Na_A(i); 
        
        Xgl(i) = Na_M4(i) / 2;
        Xparg(i) = Na_A(i);
        
        TschParg = Al_T2(i) / 2;
        Xts(i) = TschParg - Xparg(i);
        
        Reste = 1-Xgl(i)-Xparg(i)-Xts(i);
        Xtr(i) = XMg(i) * Reste;
        Xftr(i) = XFe(i) * Reste;
        
        
        
        if Aliv(i) < 0 || Alvi(i) < 0 || Al_T2(i) < 0 || Al_M2(i) < 0 || ...
           Mg_M2(i) < 0 || Fe_M2(i) < 0 || Mg_M13(i) < 0 || Fe_M13(i) < 0 || ...
           Ca_M4(i) < 0 || Na_M4(i) < 0 || Na_A(i) < 0 || V_A(i) < 0
            
            Si4(i) = 0;
            Aliv(i) = 0;
            Alvi(i) = 0;
            Al_T2(i) = 0;
            Al_M2(i) = 0;
            XFe(i) = 0;
            XMg(i) = 0; 
            Mg_M2(i) = 0;
            Fe_M2(i) = 0;
            Fe_M13(i) = 0;
            Mg_M13(i) = 0;
            Ca_M4(i) = 0;
            Na_M4(i) = 0;
            Na_A(i) = 0;
            V_A(i) = 0;
            Xtr(i) = 0;
            Xftr(i) = 0;
            Xts(i) = 0;
            Xparg(i) = 0;
            Xgl(i) = 0;
        end
        
    else
            Si4(i) = 0;
            Aliv(i) = 0;
            Alvi(i) = 0;
            Al_T2(i) = 0;
            Al_M2(i) = 0;
            XFe(i) = 0;
            XMg(i) = 0; 
            Mg_M2(i) = 0;
            Fe_M2(i) = 0;
            Fe_M13(i) = 0;
            Mg_M13(i) = 0;
            Ca_M4(i) = 0;
            Na_M4(i) = 0;
            Na_A(i) = 0;
            V_A(i) = 0;
            Xtr(i) = 0;
            Xftr(i) = 0;
            Xts(i) = 0;
            Xparg(i) = 0;
            Xgl(i) = 0;
    end
end

XmapWaitBar(1,handles);
return



