function [T,Xab,Xan] = ThermoFctAmphHollandA(Data,handles)
% -
% XmapTools Function (version 1.5)
% Use this function only with XmapTools 1.5.
%
% Thermometer method from Holland & Blundy (1994) equation A (with quartz). 
%
% [Values] = ThermoFctAmphLanariTa(Data);
%
% Data is a matrix with n lines and m columns. n is the number of pixel of
% the map, or the number of selected points. m is the oxyde weight values
% set in the setup file. 
% Order : SiO2 TiO2 Al2O3 FeO MnO MgO CaO Na2O K2O
%
% Setup : 
% 1>Amphibole>Amp-T H&B1994 (Amp+Pl+Qtz)>ThermoFctAmphHollandA>T Xab Xan>
%   SiO2 TiO2 Al2O3 FeO MnO MgO CaO Na2O K2O>
%
% 23 Oxygens
%
% Created by P. Lanari (Octobre 2011) - TESTED & VERIFIED 22/11/11.
% Version with pre-loading...


P = zeros(1,length(Data(:,1)));
T = zeros(1,length(Data(:,1)));
Xab = zeros(1,length(Data(:,1)));
Xan = zeros(1,length(Data(:,1)));



XmapWaitBar(0,handles);
hCompt = 1;
NbOx = 23; % Oxygens, DO NOT CHANGE !!!

% Input: Plagioclase composition

[Values] = str2num(char(inputdlg({'Xalbite (Xab)','Xanorthite (Xan)'},'Input',1,{'0.85','0.12'})));
XalbiteUser = Values(1);
XanortUser = Values(2);

clear Values 

[Values] = str2num(char(inputdlg({'Pressure (kbar)'},'Input',1,{'15'})));
Pressure = Values(1);


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



        
       
        
        laT = Testimate(Pressure,XalbiteUser,XanortUser,Si,Al,Ti,Fe,Mg,Mn,K,Ca,Na);
       
        
        

            

        P(i) = Pressure;
        T(i) = laT;
        Xab(i) = XalbiteUser;
        Xan(i) = XanortUser;
        
        
        if ~isreal(T(i)) || T(i) < 0 || T(i) > 1000
            
            P(i) = 0;
            T(i) = 0;
            Xab(i) = 0;
            Xan(i) = 0;

            
        end
        
    else
        
            P(i) = 0;
            T(i) = 0;
            Xab(i) = 0;
            Xan(i) = 0;
            
            
    end
end

XmapWaitBar(1,handles);
return



function laP = Pestimate(laT,Al) 
laP = 4.76*Al -3.01 - (((laT-675)/85)*(0.530*Al + 0.005294*(laT-675)));
return


function laT = Testimate(laP,XalbiteUser,XanortUser,Si,Al,Ti,Fe,Mg,Mn,K,Ca,Na)
% following Holland & Blundy 1994 Apendix (2)
cm = Si+Al+Ti+Fe+Mg+Mn-13;

XSi_T1 = (Si - 4) / 4;
XAl_T1 = (8 - Si) / 4;
XAl_M2 = (Al + Si - 8) / 2;
XK_A = K; % not used
XV_A = 3 - Ca - Na - K - cm; % not used
XNa_A = Ca + Na + cm - 2;
XNa_M4 = (2 - Ca - cm) / 2;
XCa_M4 = Ca/2;


% Holland & Blundy (1994) equation A with quartz
R = 0.0083144;

Y = 0;
if XalbiteUser < .5
    Y = 12*(1 - XalbiteUser)^2 - 3;
end

leHaut = -76.95 + 0.79*laP + Y + 39.4*XNa_A + 22.4*XK_A + (41.5 - 2.89*laP)*XAl_M2;
K = (27*XV_A*XSi_T1*XalbiteUser)/(256*XNa_A*XAl_T1);

laT = leHaut/( - 0.0650 - R * log(K));
laT = laT-273.15; % (�C)

return







