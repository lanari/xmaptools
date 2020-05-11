function varargout = VER_XMapTools_750(varargin)
% VER_XMAPTOOLS_750 runs the program VER_XMapTools_750
%      VER_XMAPTOOLS_750 is a MATLAB-based graphic user interface for the 
%      processing of chemical images 
%
%      VER_XMAPTOOLS_750 launches the inteface
%
%      VER_XMAPTOOLS_750 software has been created and is maintained by 
%      Dr. Pierre Lanari (pierre.lanari@geo.unibe.ch)
%
%      Find out more at http://www.ver_xmaptools_750.com
%

% VER_XMapTools_750('Untitled_1_Callback',hObject,eventdata,guidata(hObject))

%
%      VER_XMAPTOOLS_750('Property','Value',...) creates a new VER_XMAPTOOLS_750 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VER_XMapTools_750_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VER_XMapTools_750_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VER_XMapTools_750

% Last Modified by GUIDE v2.5 16-Jun-2015 09:25:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VER_XMapTools_750_OpeningFcn, ...
    'gui_OutputFcn',  @VER_XMapTools_750_OutputFcn, ...
    'gui_LayoutFcn',  @VER_XMapTools_750_LayoutFcn, ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
return
% End initialization code - DO NOT EDIT

 
%###############

% General opening function
function VER_XMapTools_750_OpeningFcn(hObject, eventdata, handles, varargin)
%
%

% 1.6.5 Activate XThermoTools for USERs
handles.XThermoToolsACTIVATION = 0;


% New 2.1.3 - VER_XMapTools_750 Commands
handles.Xmode = 'normal';
handles.Xload = '';

if iscell(varargin) && length(varargin) >= 2
    switch varargin{1}
        case 'open'
            handles.Xload = [varargin{2},'.mat'];
            
            if length(varargin) >= 4 % we can use two labels
                switch varargin{3}
                    case 'mode'
                        if isequal(varargin{4},'Xadmin')
                            handles.Xmode = 'admin';
                        end
                end
            end
            
        case 'mode'
            if isequal(varargin{2},'Xadmin')
                handles.Xmode = 'admin';
            end
    end
    
end

% New 2.1.1
if ispc
    set(gcf,'Position',[5,1.85,261,49]);
    handles.FileDirCode = 'file:/';
else
    handles.FileDirCode = 'file://';
end

archstr = computer('arch');

% New 2.1.3 Matlab version
TheVersion = strread(version,'%s','delimiter','.');
handles.MatlabVersion = str2num(TheVersion{1}) + 0.01*str2num(TheVersion{2});

set(handles.DebugMode,'visible','on');

% VER_XMapTools_750 version information                                   new 1.6.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('Local_version.txt');
localVersion =fgetl(fid);
fclose(fid); 

localStr = strread(localVersion,'%s','delimiter','-');

Version = localStr{2};  
ReleaseDate = localStr{3};               
ProgramState = localStr{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

set(handles.title2,'String',['Release ',char(Version),'-',char(ProgramState)]);
set(gcf,'Name',['XMapTools ',char(Version)]);
 

% Choose default command line output for VER_XMapTools_750
handles.output = hObject;

% Axes hide
set(handles.axes1,'Visible','off');
set(handles.axes2,'Visible','off');
set(handles.axes3,'Visible','off');

%Waitbar hidden
set(handles.UiPanelScrollBar,'visible','off');
set(handles.WaitBar1,'Visible','off');
set(handles.WaitBar2,'Visible','off');
set(handles.WaitBar3,'Visible','off');

% Config (09/2010)
fid = fopen('Config.txt');
LocBase = char(fgetl(fid)); % main directory of xmap tools
fclose(fid);
handles.LocBase = LocBase;

WhereWeAre = cd;

if isequal(LocBase,WhereWeAre)
	textAfficher = {'You are running XMapTools from your setup''s directory ...', ...
                    ' ', ...
                    'The files stored here will be deleted during the next update!', ...
                    ' ', ...
                    'Please check back the user guide for more details', ...
                    (' ')};
    
    buttonName = questdlg(textAfficher,'WARNING','Continue (not recommended)','Cancel','Cancel');
    
    switch buttonName
        case 'Cancel'
            
            handles.update = 1;
            guidata(hObject, handles);
                
            close all
            
            return
    end
    
end

% Check for update (New 2.1.1)

[onlineVersion,flag] = urlread('http://www.xmaptools.com/FTP_public2/Online_version.php');

[onlinePackage,flag] = urlread('http://www.xmaptools.com/FTP_public2/Online_package.php');

if flag
    % internet connection, we check for updates ...
    onlineStr = strread(onlineVersion,'%s','delimiter','-');
    OLVersion = onlineStr{2};
    
    LOVersion = Version;
    
    % Check if update is required
    lesOLversions = strread(OLVersion,'%f','delimiter','.');
    lesLOversions = strread(LOVersion,'%f','delimiter','.');

    if (lesLOversions(1)+lesLOversions(2)*0.01) < (lesOLversions(1)+lesOLversions(2)*0.01)     % update available
        
        while 1

            textAfficher = { ...
                        'XMapTools new updates are now available... ',...
                        ' ', ...
                        'Press the button [Update now] to automatically download and install the new release',...
                        ' ', ...
                        'Press [Info] to get details on the new release', ...
                        ' ', ...
                        ['Version: ',char(onlineVersion)],...
                        ['File: ',char(onlinePackage)], ...
                        ' '};
        

            buttonName = questdlg(textAfficher,'XMapTools updates are available','Update now','Remind me later','Info','Update now');
            
            switch buttonName

                case 'Info'
                    % Check for update (New 1.6.2)
                    [onlineUpdates,flagUpdates] = urlread('http://www.xmaptools.com/FTP_public2/Online_ListUpdates.php');

                    questdlg(onlineUpdates,'XMapTools_Updates','OK','OK');
                
                
                    
                case 'Remind me later'
                    break

                
                    
                case 'Update now'

                    %close all
                    
                    buttonName = questdlg({'XMapTools update consist of:', ...
                        '(1) delete the old files (/program)', ...
                        '(2) download the new files', ...
                        '(3) run the setup', ...
                        ' ',...
                        'Would you like to proceed?'},'Warning','OK','CANCEL','OK');
                    
                    if isequal(buttonName,'CANCEL')
                        break
                    end

                    % WARNING This is only compatible with the new VER_XMAPTOOLS_750
                    % 2.1.1 settings...
                    
                    WhereWeAre = cd;
                    
                    h = waitbar(0,'XMapTools is updating - Please wait...');
                    
                    handles.update = 1;
                    guidata(hObject, handles);
                
                    waitbar(0.2,h);
                    
                    %keyboard % before a public release... 
                    
                    % [1] Go to the VER_XMapTools_750 'program/' directory
                    cd(handles.LocBase)
                    
                    waitbar(0.3,h);
                    
                    rmpath(handles.LocBase);
                    
                    waitbar(0.4,h);
                    
                    cd ..

                    rmdir('Program','s')
                    
                    waitbar(0.6,h);

                    %passwordFTP = 'olala-lilu';
                    %userFTP = 'ftp_user@ver_xmaptools_750.com';
                    %adressFTP = 'ftp.strato.com';

                    %f = ftp(adressFTP,userFTP,passwordFTP);
                    %mget(f,'Program.zip',cd);

                    WebAdress = ['http://www.xmaptools.com/FTP_public2/',char(onlinePackage)];
                    
                    unzip(WebAdress);
                    
                    waitbar(0.9,h);
                    
                    cd Program/
                    
                    waitbar(1,h);
                    
                    close(h);
                    
                    Install_XMapTools
                    
                    cd(WhereWeAre);
                    
                    close all
                    
                    
                    return

            end
        end
    end
end
 
handles.update = 0;

%
% Addpath (version 2.1.1 - Nov 2014)
FunctionPath = strcat(LocBase,'/Functions');
addpath(FunctionPath);
ModulesPath = strcat(LocBase,'/Modules');
addpath(ModulesPath);
ModulesPath = strcat(LocBase,'/Dev');
addpath(ModulesPath);

if exist(strcat(LocBase(1:end-7),'/UserFiles')) == 7        % test if the directory exists
    FunctionPath = strcat(LocBase(1:end-7),'/UserFiles');
    addpath(FunctionPath);
end

% Path and display
set(handles.PRAffichage0,'String',LocBase);
LocAct = char(cd);
set(handles.PRAffichage01,'String',LocAct);

% Figure axes
set(handles.axes1,'xtick',[], 'ytick',[]);
set(handles.axes2,'xtick',[], 'ytick',[]);
set(handles.axes3,'xtick',[], 'ytick',[]);

% COLORMAP & load WYRK 
if handles.MatlabVersion >= 8.04
    set(handles.PopUpColormap,'String',{'Jet','Parula','WYRK','Hot','Gray','HSV','Cool','Spring','Summer','Autumn','Winter','Bone','Copper','Pink'});
else
    set(handles.PopUpColormap,'String',{'Jet','WYRK','Hot','Gray','HSV','Cool','Spring','Summer','Autumn','Winter','Bone','Copper','Pink'});
end
handles.wyrk = load('ColorScaleWYRK.txt');

% Figure auto-contrast
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;

% Graphic window
handles.PositionAxeWindow(1,:) = [0.1389 0.0914 0.8547 0.7402];
handles.PositionAxeWindow(2,:) = [0.2769 0.1872 0.5814 0.5414];
handles.PositionAxeWindow(3,:) = [0.4149 0.2830 0.3081 0.3426];
handles.PositionAxeWindowValue = 1;

% Histogram Mode
handles.HistogramMode = 0;


handles.OptionPanelDisp = 0;
handles.AdminPanelDisp = 0;

% Desactivate the X-Pad Correction Mode
set(handles.ButtonXPadApply,'UserData',0,'Visible','off');       


% ############# DIARY GESTION ##############
%

%clc

disp(' '), Date = clock;

if get(handles.ActivateDiary,'Value') % Activate Diary
    handles.diary = 1;

    DiaryName = strcat('Diary-',sprintf('%.0f %.0f %.0f %.0f %.0f',Date(1:end-1)),'.txt');
    [Success,Message,MessageID] = mkdir('XmapTools-Diary');
    diary(strcat('XmapTools-Diary/',DiaryName));
else
    handles.diary = 0;
end

TexteVersion = ['Version: ',char(Version),' - ',char(ProgramState),' - ',char(ReleaseDate)];
Ltv = length(TexteVersion);
NbBlanc = round((67-Ltv)/2);
for i=1:NbBlanc
    TexteVersion = [' ',TexteVersion];
end


disp(' ')
disp('                               * * *  ');
disp(' ')
disp('      ------------------------------------------------------- ');
disp('       #   # #   # ##### ##### ##### ##### ##### #     #####  ');
disp('        # #  ## ## #   # #   #   #   #   # #   # #     #      ');
disp('         #   # # # ##### #####   #   #   # #   # #     #####  ');
disp('        # #  #   # #   # #       #   #   # #   # #         #  ');
disp('       #   # #   # #   # #       #   ##### ##### ##### #####  ');
disp('      ------------------------------------------------------- ');
disp(' ');
disp(TexteVersion);
disp(' ');
disp('                               * * *  ');
disp(' ');
%disp([num2str(Date(3)),'/',num2str(Date(2)),'/',num2str(Date(1)),' ',num2str(Date(4)),'h',num2str(Date(5)),'''',num2str(round(Date(6))),''''''])
disp(' ');
disp(' ');
if handles.diary
    disp(['Diary   ... (activation) ... Ok']);
    disp(['Diary   ... (',char(DiaryName),') ... Ok']);
else
    disp(['Diary   ... not activated (see user''s settings)']);
end
disp(' ');

% ##############################################

disp('Loading ... (XMapTools paths) ... Ok')

if exist(strcat(LocBase(1:end-7),'/UserFiles')) == 7        % test if the directory exists
    disp('Loading ... (User files path) ... Ok');
else
    disp('Loading ... (User files path) ... Error ES0145 - /UserFiles not found (see user guide)');
end

% Defaut parameters setting :
fid = fopen('Xmap_Default.txt','r');
Compt = 1;
tline = fgets(fid);
while length(tline) > 1
  	if tline(1) ~= '!' % for comments 
     	LesElems(Compt,:) = strread(tline,'%s','delimiter',' ');
        Compt = Compt+1;
    end
    tline = fgets(fid);
end
fclose(fid);

handles.NameMaps.filename = LesElems(:,2)';
handles.NameMaps.elements = LesElems(:,1)';
handles.NameMaps.oxydes = LesElems(:,3)';
handles.NameMaps.oxydes2 = LesElems(:,4)';
handles.NameMaps.ref = [1:length(handles.NameMaps.filename)];

% handles.NameMaps.filename = {'na','mg','al','si','p','s','cl','k','ca','ti','v','cr','mn','fe','co','ni','cu','zn','zr','ag','cd','sn','ce'};
% handles.NameMaps.elements = {'Na','Mg','Al','Si','P','S','Cl','K','Ca','Ti','V','Cr','Mn','Fe','Co','Ni','Cu','Zn','Zr','Ag','Cd','Sn','Ce'};
% handles.NameMaps.oxydes = {'Na2O','MgO','Al2O3','SiO2','P2O5','SO2','Cl2O','K2O','CaO','TiO2','V2O5','Cr2O3','MnO','FeO','CoO','NiO','CuO','ZnO','ZrO2','AgO','CdO','SnO2','CeO2'};
% handles.NameMaps.oxydes2 = {'NA2O','MGO','AL2O3','SIO2','P2O5','SO2','CL2O','K2O','CAO','TIO2','V2O5','CR2O3','MNO','FEO','COO','NIO','CUO','ZNO','ZRO2','AGO','CDO','SNO2','CEO2'};
% handles.NameMaps.ref = [1:length(handles.NameMaps.filename)];

% Database of minerals : lire le fichier Mineralo.txt
% handles.NameMin.name = {'Chlorite','Mica','Biotite','Quartz','Feldspath','Plagioclase'};
% handles.NameMin.abrev = {'Chl','Mic','Biotite'};
% handles.NameMin.struct = {'FctFSChlorite','FctFSphengite'};
% handles.NameMin.ref = [1:length(handles.NameMin.name)];

handles.data.map(1).type = 0;
handles.MaskFile(1).type = 0;
handles.profils = [];

handles.quanti(1).mineral = {'none'};
handles.quanti(1).elem = [];
handles.quanti(1).listname = [];
handles.quanti(1).maskfile = [];

% Corrections settings: 
handles.corrections(1).name = 'BRC';
handles.corrections(1).value = 0;
%
handles.corrections(2).name = 'TRC';
handles.corrections(2).value = 0;

handles.CorrectionMode = 0;  % used only to hide icones during select/unselect spot analyses

handles.save = 0;
handles.results = [];

disp('Loading ... (Setting GUI parameters) ... Ok')

% ---------- TxtControl ----------
fid = fopen('Xmap_Textes.txt','r');
while 1
    LaLigne = fgetl(fid);
    if length(char(LaLigne)) == 3
        if LaLigne == 'END'
            break
        end
    end
    OnLit = 1;
    if LaLigne(1) == '!' || LaLigne(1) == '-'
        OnLit = 0;
    end
    if OnLit
        A = strread(char(LaLigne),'%s','delimiter','<');
        
        B = strread(char(A(1)),'%s','delimiter','.');
        Elemtxt = str2num(char(B(1)));
        Outxt = str2num(char(B(2)));
        
        Txt = char(A(2));
        TxtForm = Txt(3:end);
        
        LeCode = str2num(Txt(1));
        
        TxtDatabase(Elemtxt).txt{Outxt} = TxtForm; 
        TxtDatabase(Elemtxt).Color(Outxt) = LeCode;

    end
end
fclose(fid);
handles.TxtDatabase = TxtDatabase;

set(handles.DisplayComments,'Value',1); % object

% Update handles structure
guidata(hObject, handles);

CodeTxt = [13,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

disp('Loading ... (Help texts) ... Ok')

% ---------- Structural Formulas and ThermoBaro functions ----------
% ...
% New 1.6.4 (P. Lanari 03/08/2013)
% Notes:
%      * Compatible with External variables (if defined)

if isequal(exist('ListFunctions_USER.txt'),2)
    fid = fopen('ListFunctions_USER.txt');
else
    fid = fopen('ListFunctions.txt');
end

Compt = 1;
tline = fgets(fid);
lesFormules = cell(1,7);
while length(tline) > 1
  	if tline(1) ~= '!' % for commented lines 
     	TheLine = strread(tline,'%s','delimiter','>');
        if length(TheLine) == 6                                     % 1.6.4
            lesFormules(Compt,1:6) = TheLine;     
            lesFormules{Compt,7} = '';            % Empty external variable
        else
            lesFormules(Compt,1:7) = TheLine;
        end
        Compt = Compt+1;
    end
    tline = fgets(fid);
end
fclose(fid);

% Variable ExternalFunctions with all the informations (different types)
externalFunctions(1).listMin = {};
externalFunctions(2).listMin = {};
externalFunctions(3).listMin = {};
externalFunctions(4).listMin = {};

for i=1:length(lesFormules(:,1))
    leCase = str2double(char(lesFormules(i,1)));

    readNameMin = lesFormules(i,2);

    Ou = find(ismember(externalFunctions(leCase).listMin,readNameMin));
    if isempty(Ou)
        onEcrit = length(externalFunctions(leCase).listMin) + 1;
        compt1 = 1;
    else
        onEcrit = Ou;
        compt1 = length(externalFunctions(leCase).minerals(onEcrit).listMeth) + 1;
    end

    externalFunctions(leCase).listMin{onEcrit} = char(readNameMin);
    externalFunctions(leCase).minerals(onEcrit).name = char(readNameMin);            
    externalFunctions(leCase).minerals(onEcrit).listMeth(compt1) = lesFormules(i,3);

    externalFunctions(leCase).minerals(onEcrit).method(compt1).name = lesFormules(i,3);
    externalFunctions(leCase).minerals(onEcrit).method(compt1).file = lesFormules(i,4);
    externalFunctions(leCase).minerals(onEcrit).method(compt1).output = strread(char(lesFormules(i,5)),'%s','delimiter',' ');
    externalFunctions(leCase).minerals(onEcrit).method(compt1).input = strread(char(lesFormules(i,6)),'%s','delimiter',' ');

    % 1.6.4
	if char(lesFormules(i,7)) % external variable
        TheExternal = char(lesFormules(i,7));
        TheExternalSepar = strread(TheExternal,'%s','delimiter',')');
        clear TheExternalFinal
        for j=1:length(TheExternalSepar)
            TheExternalFinal = strread(char(TheExternalSepar{j}),'%s','delimiter','(');
            externalFunctions(leCase).minerals(onEcrit).method(compt1).variables{j} = TheExternalFinal{1};
            externalFunctions(leCase).minerals(onEcrit).method(compt1).varvals{j} = TheExternalFinal{2};
        end
    else
        externalFunctions(leCase).minerals(onEcrit).method(compt1).variables = {''};
        externalFunctions(leCase).minerals(onEcrit).method(compt1).varvals = {''};
    end
end
 
% update the menu lists (version 1.6.2):

set(handles.THppmenu3,'Value',1); % default: structural formulas

set(handles.THppmenu1,'String',externalFunctions(1).listMin);
set(handles.THppmenu1,'Value',1);

set(handles.THppmenu2,'String',externalFunctions(1).minerals(1).listMeth);
set(handles.THppmenu2,'Value',1);


handles.externalFunctions = externalFunctions;


if 0
    % ---------- Thermometers ----------
    fid = fopen('ListThermometers.txt');
    Compt = 1;
    tline = fgets(fid);
    while length(tline) > 1
        if tline(1) ~= '!' % for comments 
            LesFormules(Compt,1:6) = strread(tline,'%s','delimiter','>');
            Compt = Compt+1;
        end
        tline = fgets(fid);
    end
    fclose(fid);
    for i=1:length(LesFormules(:,1)) % UPDATED 1.4.2
        % Organisation:
        Thermometers(i).type = str2num(char(LesFormules(i,1)));
        Thermometers(i).mineral = LesFormules(i,2);
        Thermometers(i).name = LesFormules(i,3);
        Thermometers(i).file = LesFormules(i,4);
        Thermometers(i).output = strread(char(LesFormules(i,5)),'%s','delimiter',' ');
        Thermometers(i).input = strread(char(LesFormules(i,6)),'%s','delimiter',' ');
    end

    ListMin(1) = Thermometers(1).mineral;
    Thermo(1).name = Thermometers(1).mineral;
    Thermo(1).thermometers(1) = Thermometers(1);


    for i=2:length(Thermometers)
        LeMin = Thermometers(i).mineral;
        [oui,ou] = ismember(LeMin,ListMin);
        if oui % know mineral
            Thermo(ou).thermometers(length(Thermo(ou).thermometers)+1) = Thermometers(i);
        else
            ListMin(length(ListMin)+1) = LeMin;
            OnestOu = length(Thermo)+1;
            Thermo(OnestOu).name = LeMin;
            Thermo(OnestOu).thermometers(1) = Thermometers(i);
        end
    end

    set(handles.THppmenu1,'String',ListMin);
    set(handles.THppmenu1,'Value',1);

    for i=1:length(Thermo(1).thermometers)
        ListThermo(i) = Thermo(1).thermometers(i).name;
    end

    set(handles.THppmenu2,'String',ListThermo);
    set(handles.THppmenu2,'Value',1);

    handles.thermo = Thermo;
end

if isequal(exist('ListFunctions_USER.txt'),2)
    disp('Loading ... (External functions: ListFunctions_USER.txt [user file]) ... Ok'), 
    disp(' ')
    disp('WARNING - You are not using the XMapTools default file ListFunction.txt (see above) !!!')
    disp(' ')
else
    disp('Loading ... (External functions: ListFunctions.txt [default]) ... Ok'), disp(' ')
end




% ---------- Masks methods ----------
MethodList = {'Classic computation','Normalized intensities'};
set(handles.PPMaskMeth,'String',MethodList);
set(handles.PPMaskMeth,'Value',2);

% ---------- Quantification methods ----------
MethodListQuanti = {'Auto (median approach)','Manual (user selection)','Manual (homogeneous phase)','Transfert to quanti'};
set(handles.QUmethod,'String',MethodListQuanti);


% ---------- Display options ----------
handles.rotateFig = 0;


% update display MaJ 1.4.1
AffOPT(1, hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);

% Update Environnement
FigureInitialization(hObject, eventdata, handles);
OnEstOu(hObject, eventdata, handles);



% ---------- Additional functions (new 2.1.3) ---------- 
if length(handles.Xload)
    % we must open a project...
    if exist(handles.Xload) == 2
        XMapTools_LoadProject(hObject, eventdata, handles, handles.Xload, handles.Xload);
    end
end

if isequal(handles.Xmode,'admin')
    iconsFolder = fullfile(get(handles.PRAffichage0,'String'),'/Dev/img/');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'administrator.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.ADMINbutton1,'string',str,'visible','on','TooltipString','Open admin panel');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'shell.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.DebugMode,'string',str,'visible','on','TooltipString','Debug mode [ADMIN]');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'shell.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton8,'string',str,'visible','on','TooltipString','Grain Boundary Orientation [ADMIN]');

else
    set(handles.ADMINbutton1,'visible','off');
end


if isequal(handles.Xmode,'admin')
    disp('XMapTools [ADMIN] is ready to work, take care!')
else
    disp('XMapTools is ready to work, enjoy it!')
end
disp(' ')


return

% General output function
function varargout = VER_XMapTools_750_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [1];% handles.output;
%keyboard
return



% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%                          FONCTIONS GENERALES (V1.6)
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



% #########################################################################
%     ABOUT VER_XMAPTOOLS_750... V1.5.4
function AboutXMapTools_Callback(hObject, eventdata, handles)
warndlg({' ', ...
         'XMapTools has been created by Pierre Lanari', ...
         'contact: pierre.lanari@geo.unibe.ch', ...
         ' ', ...
         'find out more at http://www.xmaptools.com', ...
         ' ',' ', ...
         '>> XMapTools License Policies: ', ...
         ' ', ...
         'XMapTools is distributed in an Double Regime: Academic and Commercial. In the Academic and Public Research World XMapTools is distributed under the terms of the Scientific Software Open Source Academic For Free License. This License sets the code GRATIS and Open Source and grants Freedom to use copy study modify and redistribute it. But these policies hold only within the Academic and Public Research world. In the Commercial World XMapTools is going to be distributed under other Licenses, to be negotiated from case to case. In this case it is a paying code, and exclusiveness for a certain merceological sector, or even full exclusiveness can be agreed with commercial institutions.',...
         ' ',' ',' ',},'About XMapTools... ');
return


function FigureInitialization(hObject, eventdata, handles)
%

iconsFolder = fullfile(get(handles.PRAffichage0,'String'),'/Dev/img/');

%set(handles.OPT1,'TooltipString','X-ray mode')
%set(handles.OPT2,'TooltipString','Quanti mode')
%set(handles.OPT3,'TooltipString','Result mode')


% Here the buttons that don't need update...

iconUrl = strrep([handles.FileDirCode, iconsFolder 'box_open.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.Button2,'string',str,'TooltipString','Open existing project ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'new_window.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.Button1,'string',str,'TooltipString','Close and open a new XMapTools window ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'cross.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.Button4,'string',str,'TooltipString','Close and exit XMapTools ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'setting_tools.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.ButtonSettings,'string',str,'TooltipString','XMapTools settings ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'information.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.AboutXMapTools,'string',str,'TooltipString','XMapTools info ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'picture_add.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.MButton1,'string',str,'TooltipString','Import map(s) ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_up.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.ButtonUp,'string',str,'TooltipString','Move up ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_down.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.ButtonDown,'string',str,'TooltipString','Move down ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_right.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.ButtonRight,'string',str,'TooltipString','Move right ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_left.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.ButtonLeft,'string',str,'TooltipString','Move left ...');

iconUrl = strrep([handles.FileDirCode, iconsFolder 'info_rhombus.png'],'\','/');
str = ['<html><img src="' iconUrl '"/></html>'];
set(handles.THbutton2,'string',str,'TooltipString','Information ...');


% Default settings  (New 2.1.1)
load([handles.LocBase,'/Default_XMapTools.mat']);

set(handles.DisplayComments,'Value',Default_XMapTools(1));
set(handles.ActivateDiary,'Value',Default_XMapTools(2));
set(handles.DisplayActions,'Value',Default_XMapTools(3));
set(handles.DisplayCoordinates,'Value',Default_XMapTools(4));
set(handles.PopUpColormap,'Value',Default_XMapTools(5));

DisplayComments_Callback(hObject, eventdata, handles);


guidata(hObject, handles);
return




% #########################################################################
%     FONCTION ON EST OU
function OnEstOu(hObject, eventdata, handles)
%

% main directory of the icons...
iconsFolder = fullfile(get(handles.PRAffichage0,'String'),'/Dev/img/');
    
% Display update
set(handles.SamplingDisplay,'String','');

if isequal(get(handles.ButtonXPadApply,'UserData'),0)
    CorrectionMode = 0;
else
    CorrectionMode = 1;
end

if handles.HistogramMode && ~CorrectionMode   % We are using the Correction Mode for the histogram mode...
    CorrectionMode = 1;
end   

if handles.CorrectionMode
    CorrectionMode = 1;
end

% Button Credits
%str = '<HTML><center>Find out more at <br /><a href="http://www.ver_xmaptools_750.com">www.ver_xmaptools_750.com</a></center></HTML>';
%jDispLink = findjobj(handles.DispLink);
%jDispLink.setContentAreaFilled(0);
%jDispLink.setBorder([]);

    
% 0) FIGURE
if length(get(handles.axes1,'Visible')) == 2 && ~CorrectionMode
    % On affiche les options
    set(handles.ExportWindow,'Enable','on');
    set(handles.checkbox1,'Enable','on');
    set(handles.checkbox7,'Enable','on');
    set(handles.FIGbutton1,'Enable','on');
    set(handles.FIGtext1,'Enable','on');
    set(handles.ColorMin,'Enable','on');
    set(handles.ColorMax,'Enable','on');
    set(handles.ColorButton1,'Enable','on');
    
    %set(handles.BUsampling1,'Enable','on');
    set(handles.BUsampling2,'Enable','on');
    set(handles.BUsampling3,'Enable','on');
    set(handles.BUsampling4,'Enable','on');
    %set(handles.SamplingDisplay,'Enable','on');
    
    set(handles.PopUpColormap,'Enable','on');
    set(handles.RotateButton,'Enable','on');
    
    set(handles.ButtonFigureMode,'Enable','on');
    set(handles.ButtonWindowSize,'Enable','on');
    
    set(handles.text77,'Enable','on');  % black layer text
    
    
    % Icons that do not need to be hidden in HISTOGRAM mode: 

    if handles.AutoContrastActiv
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'magic_wand_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ColorButton1,'string',str,'TooltipString','Disable auto-contrast ...');
    else
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'magic_wand.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ColorButton1,'string',str,'TooltipString','Enable auto-contrast ...');
    end
    
    if handles.MedianFilterActiv
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_delete.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.FIGbutton1,'string',str,'TooltipString','Disable median-filter ...');
    else
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_add.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.FIGbutton1,'string',str,'TooltipString','Enable median-filter ...');
    end
    
    % Axes1 Window and size
    set(handles.uipanel59,'Position',handles.PositionAxeWindow(handles.PositionAxeWindowValue,:));
    set(handles.uipanel60,'Position',handles.PositionAxeWindow(handles.PositionAxeWindowValue,:));
    
    if handles.PositionAxeWindowValue == 1 || handles.PositionAxeWindowValue == 2
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_resize_actual.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonWindowSize,'string',str,'TooltipString','Reduce size of display window ...');
    else
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_resize.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonWindowSize,'string',str,'TooltipString','Increase size of display window ...');
    end
    

    % HISTOGRAM MODE 
    
    % Now we arrive here if HistogramMode = 0.  (and in the next loop if HistogramMode = 1)
    
    if handles.HistogramMode                  % if HISTOGRAM mode is ACTIVE
         set(handles.uipanel60,'visible','on');
         set(handles.uipanel59,'visible','off');
         
         set(handles.ButtonFigureMode,'Enable','on');
         
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_raster.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonFigureMode,'string',str,'TooltipString','Disable histogram mode (back to mapping mode) ...');

         
         
    else                                  % if HISTOGRAM mode is NOT ACTIVE
        set(handles.uipanel60,'visible','off');
        set(handles.uipanel59,'visible','on');
        
        set(handles.ButtonFigureMode,'Enable','on');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_histogram.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonFigureMode,'string',str,'TooltipString','Enable histogram mode ...');

    end
     
        
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'export.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.ExportWindow,'string',str,'TooltipString','Export displayed image ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_rotate.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.RotateButton,'string',str,'TooltipString','Rotate the figure of 90° (counterclockwise) ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'draw_line.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling2,'string',str,'TooltipString','Sampling: line mode ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'select_lasso.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling3,'string',str,'TooltipString','Sampling: area mode ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'draw_rectangle.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling4,'string',str,'TooltipString','Sampling: integrated line mode ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'format_percentage.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MButton4,'string',str,'TooltipString','Display precision map (in %) ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'info_rhombus.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MButton3,'string',str,'TooltipString','Display "info" window ...');

    
else
    
    % Now we arrive here if HistogramMode = 1  / Corr mode = 1 .
    
    if handles.HistogramMode                  % if HISTOGRAM mode is ACTIVE
         set(handles.uipanel60,'visible','on');
         set(handles.uipanel59,'visible','off');
         
         set(handles.ButtonFigureMode,'Enable','on');
         
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_raster.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonFigureMode,'string',str,'TooltipString','Disable histogram mode (back to mapping mode) ...');

         
         
    else                                  % if HISTOGRAM mode is NOT ACTIVE
        set(handles.uipanel60,'visible','off');
        set(handles.uipanel59,'visible','on');
        
        set(handles.ButtonFigureMode,'Enable','off');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_histogram_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.ButtonFigureMode,'string',str);

    end
    
    set(handles.ExportWindow,'Enable','off');
    set(handles.checkbox1,'Enable','off');
    set(handles.checkbox7,'Enable','off');
    set(handles.FIGbutton1,'Enable','off');
    set(handles.FIGtext1,'Enable','off');
    set(handles.ColorMin,'Enable','off');
    set(handles.ColorMax,'Enable','off');
    set(handles.ColorButton1,'Enable','off');
    
    %set(handles.BUsampling1,'Enable','off');
    set(handles.BUsampling2,'Enable','off');
    set(handles.BUsampling3,'Enable','off');
    set(handles.BUsampling4,'Enable','off');
    set(handles.SamplingDisplay,'Enable','inactive');
    
    set(handles.RotateButton,'Enable','off');
    set(handles.PopUpColormap,'Enable','off');
    
    %set(handles.ButtonFigureMode,'Enable','off');
    set(handles.ButtonWindowSize,'Enable','off');
    
    set(handles.text77,'Enable','off');  % black layer text
    
    % Images: 
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'export_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.ExportWindow,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'arrow_rotate_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.RotateButton,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'magic_wand_bw_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.ColorButton1,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_add_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.FIGbutton1,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_resize_actual_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.ButtonWindowSize,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'draw_line_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling2,'string',str);
        
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'select_lasso_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling3,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'draw_rectangle_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.BUsampling4,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'format_percentage_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MButton4,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'info_rhombus_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MButton3,'string',str);
    
end


% 1) RAW DATA
data = handles.data;
if length(data.map) == 1 || CorrectionMode
    % avec ou sans maps:
    if data.map(1).type == 0 || CorrectionMode
        set(handles.PPMenu1,'Enable','off');
        set(handles.MButton2,'Enable','off');
        set(handles.MButton3,'Enable','off');
        set(handles.MButton4,'Enable','off');
        set(handles.PPMaskMeth,'Enable','off');
        set(handles.PPMaskFrom,'Enable','off');
        set(handles.MaskButton1,'Enable','off');
        set(handles.PRButton1,'Enable','off'); % Pas de profils sans maps
        set(handles.MaskButton7,'Enable','off');
        
        set(handles.Button3,'Enable','off'); % pas de sauvegarde
        set(handles.Button5,'Enable','off');
        
        %set(handles.Tranfert2Quanti,'Enable','off'); % pas de TTQUanti
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_open_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.PRButton1,'string',str);
    
        % Images: 
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_data_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.Button3,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_as_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.Button5,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MaskButton7,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'picture_delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MButton2,'string',str);
        
        Ou.data = 0; % Etat
    else
        set(handles.PPMenu1,'Enable','on');
        set(handles.MButton2,'Enable','off');
        set(handles.MButton3,'Enable','on');
        set(handles.MButton4,'Enable','on');
        set(handles.PPMaskMeth,'Enable','off');
        set(handles.PPMaskFrom,'Enable','off');
        set(handles.MaskButton1,'Enable','off');
        set(handles.PRButton1,'Enable','on');
        set(handles.MaskButton7,'Enable','off');
        
        set(handles.Button3,'Enable','on'); 
        set(handles.Button5,'Enable','on');
        
        %set(handles.Tranfert2Quanti,'Enable','off'); % pas de TTQUanti
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_open.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.PRButton1,'string',str,'TooltipString','Import standard file ...');
        
        %
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_data.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.Button3,'string',str,'TooltipString','Save the project ...');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_as.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.Button5,'string',str,'TooltipString','Save the project as ...');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MaskButton7,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'picture_delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MButton2,'string',str);
        
        Ou.data = 1; % Etat
    end
else
    % On charge tout
    set(handles.PPMenu1,'Enable','on');
    set(handles.MButton2,'Enable','on');
    set(handles.MButton3,'Enable','on');
    set(handles.MButton4,'Enable','on');
    set(handles.PPMaskMeth,'Enable','on');
    set(handles.PPMaskFrom,'Enable','on');
    set(handles.MaskButton1,'Enable','on');
    set(handles.PRButton1,'Enable','on');
    set(handles.MaskButton7,'Enable','on');
    
    set(handles.Button3,'Enable','on'); 
    set(handles.Button5,'Enable','on');
    
    %set(handles.Tranfert2Quanti,'Enable','on');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_open_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton1,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'layer_open.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton1,'string',str,'TooltipString','Import standard file ...');
    
    %
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_data.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.Button3,'string',str,'TooltipString','Save the project ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'save_as.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.Button5,'string',str,'TooltipString','Save the project as ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton7,'string',str,'TooltipString','Import and merge maskfile(s) ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'picture_delete.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MButton2,'string',str,'TooltipString','Delete map ...');

    Ou.data = 2; % Etat
end


% 2) PROFILS
if length(handles.profils) < 1 || CorrectionMode
    set(handles.PRButton5,'Enable','off');
    set(handles.PRButton3,'Enable','off');
    set(handles.PRButton4,'Enable','off');
 %   set(handles.PRButton2,'Enable','off'); % deleted in 2.1.3
    set(handles.PRButton7,'Enable','off');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'chart_curve_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton5,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'lightbulb_add_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton3,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'lightbulb_delete_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton4,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'check_box_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton7,'string',str);
    
    
    Ou.profil = 0;
else
    set(handles.PRButton5,'Enable','on');
    set(handles.PRButton3,'Enable','on');
    set(handles.PRButton4,'Enable','on');
    %set(handles.PRButton2,'Enable','on');
    set(handles.PRButton7,'Enable','on');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'chart_curve.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton5,'string',str,'TooltipString','Display intensity vs composition chart ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'lightbulb_add.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton3,'string',str,'TooltipString','Display standards ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'lightbulb_delete.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton4,'string',str,'TooltipString','Hide standards ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'check_box.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.PRButton7,'string',str,'TooltipString','Check quality of std/maps positions');
    
    
    Ou.profil = 1;
end


% 3) MASQUES
if handles.MaskFile(1).type == 0 || CorrectionMode
    set(handles.PPMenu2,'Enable','off');
    set(handles.PPMenu3,'Enable','off');
    set(handles.MaskButton2,'Enable','off');
    set(handles.MaskButton4,'Enable','off');
    set(handles.MaskButton3,'Enable','off');
    set(handles.MaskButton6,'Enable','off');
    
    set(handles.MaskButton5,'Enable','off'); % pas de bouton delete
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton2,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_go_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton6,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'export_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton4,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_edit_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton3,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_delete_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton5,'string',str);
    
    
    Ou.masques = 0;
else
    set(handles.PPMenu2,'Enable','on');
    set(handles.PPMenu3,'Enable','on');
    set(handles.MaskButton2,'Enable','on');
    set(handles.MaskButton4,'Enable','on');
    set(handles.MaskButton3,'Enable','on');
    set(handles.MaskButton6,'Enable','on');
    
    Ou.masques = 1;
    
    if length(handles.MaskFile) > 1 % il faut au moins 2 masques pour en supp 1
        set(handles.MaskButton5,'Enable','on');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_delete.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MaskButton5,'string',str,'TooltipString','Delete maskfile ...');
        
    else
        set(handles.MaskButton5,'Enable','off');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.MaskButton5,'string',str);
        
    end
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton2,'string',str,'TooltipString','Display mask image ...');

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_go.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton6,'string',str,'TooltipString','Export phase proportions ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'export.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton4,'string',str,'TooltipString','Export mask image ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'map_edit.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.MaskButton3,'string',str,'TooltipString','Rename phases ...');
    
    
    
end

%On Affichage des bouttons profils que si XRay map

% - - Change ici le 10 Octobre 2011 - Version 1.4.3
% - - En effet, problème d'affichage au retour à la partie Raw
% - - Comme chaque partie affiche son image, on peut laisser les bouttons
% - - dispo...

% if get(handles.QUppmenu2,'Value') > 1 || get(handles.REppmenu1,'Value') > 1
%     set(handles.PRButton3,'Enable','off')
%     set(handles.PRButton4,'Enable','off')
% end
% if get(handles.QUppmenu2,'Value') == 0 && get(handles.REppmenu1,'Value') == 0 && Ou.profil == 1
%     set(handles.PRButton3,'Enable','on')
%     set(handles.PRButton4,'Enable','on')
% end
    
% 4) CORRECTIONS
if  isequal(handles.corrections(1).value,1) && isequal(get(handles.OPT1,'value'),1) && ~CorrectionMode
    set(handles.CorrButtonBRC,'Enable','on');
else
    set(handles.CorrButtonBRC,'Enable','off');
end

% if  isequal(handles.corrections(2).value,1)
%     set(handles.CorrButtonTRC,'Enable','on');
% else
%     set(handles.CorrButtonTRC,'Enable','off');
% end


if length(get(handles.axes1,'Visible')) == 3    % Activate this if we have data
    set(handles.CorrButton1,'Enable','off');
    set(handles.CorrPopUpMenu1,'Enable','off');
else
    if get(handles.CorrPopUpMenu1,'Value') >= 2 && ~CorrectionMode
        
        CorrPopUpMenu1_Callback(hObject, eventdata, handles) % udpate...
        
    else
        set(handles.CorrButton1,'Enable','off');
    end
    set(handles.CorrPopUpMenu1,'Enable','on');
end



% 5) STANDARDIZATION


if get(handles.PPMenu2,'Value') > 1 && Ou.data == 2 && Ou.profil == 1 && Ou.masques == 1 
    set(handles.QUButton1,'Enable','on');
    Ou.xray = 1;                          % not sure if this is till useful
else
    set(handles.QUButton1,'Enable','off');
    Ou.xray = 0;
end

if get(handles.QUmethod,'value') == 4 && Ou.data >= 1
    set(handles.QUButton1,'String','TRANSFERT','Enable','on');
else
    set(handles.QUButton1,'String','STANDARDIZE');
end



% % old version < 2.1.1
% if Ou.data == 2 && Ou.profil == 1 && Ou.masques == 1 && get(handles.PPMenu2,'Value') > 1
%     set(handles.QUButton1,'Enable','on');
%     set(handles.QUmethod,'Enable','on');
%     Ou.xray = 0;
%     if Ou.data == 2 && Ou.profil == 1 && Ou.masques == 1
%         set(handles.TXTquanti,'String','...');
%     end
% else
%     if Ou.data == 2 && Ou.profil == 1 && Ou.masques == 1
%         set(handles.TXTquanti,'String','Select a mask to standardize');
%     end
%     set(handles.QUButton1,'Enable','off');
%     set(handles.QUmethod,'Enable','off');
%     Ou.xray = 1;
% end

% 5) QUANTI
if length(handles.quanti) == 1 || CorrectionMode
    set(handles.QUppmenu2,'Enable','off');
    set(handles.QUppmenu1,'Enable','off');
    set(handles.QUbutton0,'Enable','off');
    set(handles.QUbutton11,'Enable','off');
    set(handles.QUbutton_TEST,'Enable','off');
    set(handles.QUbutton2,'Enable','off');
    set(handles.QUbutton3,'Enable','off');
    set(handles.THbutton1,'Enable','off');
    set(handles.QUbutton4,'Enable','off');
    
    set(handles.QUbutton5,'Enable','off');
    set(handles.MergeInterpBoundaries,'Enable','off');
    set(handles.QUbutton6,'Enable','off');
    set(handles.QUbutton7,'Enable','off');
    
    set(handles.QUbutton8,'Enable','off');
    set(handles.QUbutton9,'Enable','off');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton4,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton0,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton2,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_advanced_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton8,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'sum_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton3,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'check_box_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton_TEST,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'chart_curve_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton11,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton5,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_map_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton6,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_area_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton7,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_prop_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.QUbutton9,'string',str);
    
else
    set(handles.QUppmenu2,'Enable','on');
    if get(handles.QUppmenu2,'Value') > 1 % actif
        set(handles.QUppmenu1,'Enable','on');
        set(handles.QUbutton3,'Enable','on');
        set(handles.QUbutton2,'Enable','on');
        set(handles.THbutton1,'Enable','on');
        set(handles.QUbutton4,'Enable','on');
        
        set(handles.QUbutton8,'Enable','on');
        
        TheText = get(handles.QUtexte1,'String');
        NbPoints = str2num(TheText(1:end-4));
        if NbPoints && get(handles.QUppmenu2,'Value') >= 2
            set(handles.QUbutton11,'Enable','on');
            set(handles.QUbutton_TEST,'Enable','on');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'check_box.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton_TEST,'string',str,'TooltipString','Check quality of standardization ...');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'chart_curve.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton11,'string',str,'TooltipString','Plot itensity vs wt.% callibrations ...');
            
        else
            set(handles.QUbutton11,'Enable','off');
            set(handles.QUbutton_TEST,'Enable','off');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'check_box_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton_TEST,'string',str);
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'chart_curve_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton11,'string',str);
            
        end
        
        
        if length(get(handles.QUppmenu2,'String')) > 2
            set(handles.QUbutton0,'Enable','on');
            set(handles.QUbutton5,'Enable','on');
            set(handles.MergeInterpBoundaries,'Enable','on');
            set(handles.QUbutton6,'Enable','on');
            set(handles.QUbutton7,'Enable','on');
            set(handles.QUbutton9,'Enable','on');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton0,'string',str,'TooltipString','Delete Quanti file ...');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton5,'string',str,'TooltipString','Merge Quanti files (maps) ...');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_map.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton6,'string',str,'TooltipString','Export local composition: map ...');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_area.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton7,'string',str,'TooltipString','Export local composition: area ...');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_prop.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton9,'string',str,'TooltipString','Export composition build from proportions ...');
            
        else
            set(handles.QUbutton0,'Enable','off');
            set(handles.QUbutton5,'Enable','off');
            set(handles.MergeInterpBoundaries,'Enable','off');
            set(handles.QUbutton6,'Enable','off');
            set(handles.QUbutton7,'Enable','off');
            set(handles.QUbutton9,'Enable','off');
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton0,'string',str);
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton5,'string',str);
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_map_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton6,'string',str);
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_area_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton7,'string',str);
            
            iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_prop_bw.png'],'\','/');
            str = ['<html><img src="' iconUrl '"/></html>'];
            set(handles.QUbutton9,'string',str);

        end
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton4,'string',str,'TooltipString','Rename Quanti file ...');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton2,'string',str,'TooltipString','Export compositions ...');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_advanced.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton8,'string',str,'TooltipString','Apply filter (between min and max values) ...');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'sum.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton3,'string',str,'TooltipString','Generate the Oxide wt.% sum map ...');
        
    else
        set(handles.QUbutton0,'Enable','off');
        set(handles.QUppmenu1,'Enable','off');
        set(handles.QUbutton11,'Enable','off');
        set(handles.QUbutton_TEST,'Enable','off');
        set(handles.QUbutton3,'Enable','off');
        set(handles.QUbutton2,'Enable','off');
        set(handles.THbutton1,'Enable','off');
        set(handles.QUbutton4,'Enable','off');
        set(handles.QUbutton5,'Enable','off');
        set(handles.MergeInterpBoundaries,'Enable','off');
        set(handles.QUbutton6,'Enable','off');
        set(handles.QUbutton7,'Enable','off');
        set(handles.QUbutton8,'Enable','off');
        set(handles.QUbutton9,'Enable','off');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton4,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton0,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton2,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'filter_advanced_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton8,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'sum_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton3,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'layers_map_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton5,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_map_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton6,'string',str);

        iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_area_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton7,'string',str);

        iconUrl = strrep([handles.FileDirCode, iconsFolder 'compo_prop_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.QUbutton9,'string',str);
        
    end
end

set(handles.THppmenu3,'Enable','on');

% Update of the menu for XThermotools                             new 1.6.5
THppmenu3_Callback(hObject, eventdata, handles)



% 6) QUANTI BULK-COMPOSITION 
% note pour la suite, il suffi ici d'avoir deux cartes ou plus pour 
% activer le premier bouton qui declenchera les autres en chaine. 


%6) RESULTATS
results = handles.results;
if length(results) && ~CorrectionMode
    set(handles.REppmenu1,'Enable','on');
    set(handles.REppmenu2,'Enable','on');
    
    set(handles.REbutton1,'Enable','on');
    set(handles.REbutton3,'Enable','on');
    set(handles.REbutton4,'Enable','on');
    
    set(handles.REbutton7,'Enable','on');
    set(handles.REbutton8,'Enable','on');
    
    set(handles.FilterMin,'Enable','inactive');
    set(handles.FilterMax,'Enable','inactive');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton1,'string',str,'TooltipString','Rename Result file ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton3,'string',str,'TooltipString','Export compositions ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton7,'string',str,'TooltipString','Compute new variable ...');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number_remove.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton8,'string',str,'TooltipString','Delete variable ...');
    
    if length(results) >= 2
        set(handles.REbutton2,'Enable','on'); % delete
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton2,'string',str,'TooltipString','Delete Result file ...');
        
    else
        set(handles.REbutton2,'Enable','off'); % delete
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton2,'string',str);
        
    end

%     if length(get(handles.REppmenu2,'String')) >= 3
%         set(handles.REbutton6,'Enable','on'); % triplot
%     else
%         set(handles.REbutton6,'Enable','off');
%     end
%     if length(get(handles.REppmenu2,'String')) >= 2
%         set(handles.REbutton5,'Enable','on'); % triplot
%         
%     else
%         %set(handles.REbutton5,'Enable','off');
%         
%     end
    
    if get(handles.REppmenu1,'Value') == 1;
        set(handles.REppmenu2,'Enable','off');
        set(handles.REbutton1,'Enable','off');
        set(handles.REbutton2,'Enable','off');
        set(handles.REbutton3,'Enable','off');
        set(handles.REbutton4,'Enable','off');
        %set(handles.REbutton5,'Enable','off');
        %set(handles.REbutton6,'Enable','off');
        
        set(handles.REbutton7,'Enable','off');
        set(handles.REbutton8,'Enable','off');
        
        set(handles.FilterMin,'Enable','off');
        set(handles.FilterMax,'Enable','off');
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton2,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton1,'string',str);

        iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton3,'string',str);
        
        iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton7,'string',str);

        iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number_remove_bw.png'],'\','/');
        str = ['<html><img src="' iconUrl '"/></html>'];
        set(handles.REbutton8,'string',str);
        
        
    end
else
    set(handles.REppmenu1,'Enable','off');
    set(handles.REppmenu2,'Enable','off');
    set(handles.REbutton1,'Enable','off');
    set(handles.REbutton2,'Enable','off');
    set(handles.REbutton3,'Enable','off');
    set(handles.REbutton4,'Enable','off');
    %set(handles.REbutton5,'Enable','off');
    %set(handles.REbutton6,'Enable','off');
    
    set(handles.REbutton7,'Enable','off');
    set(handles.REbutton8,'Enable','off');
    
    set(handles.FilterMin,'Enable','off');
    set(handles.FilterMax,'Enable','off');
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'delete_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton2,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'textfield_rename_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton1,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'text_exports_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton3,'string',str);
    
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton7,'string',str);

    iconUrl = strrep([handles.FileDirCode, iconsFolder 'slide_number_remove_bw.png'],'\','/');
    str = ['<html><img src="' iconUrl '"/></html>'];
    set(handles.REbutton8,'string',str);
    
end


% Special TriPlot and Scheme2D

if get(handles.OPT1,'Value') 
    if iscellstr(get(handles.PPMenu1,'String')) && ~CorrectionMode % you should have more than tree maps loaded
        if length(get(handles.PPMenu1,'String')) >= 2
            set(handles.REbutton5,'Enable','on');
        else
            set(handles.REbutton5,'Enable','off');
        end
        if length(get(handles.PPMenu1,'String')) >= 3
            set(handles.REbutton6,'Enable','on');
        else
            set(handles.REbutton6,'Enable','off');
        end
    else
        set(handles.REbutton5,'Enable','off');
        set(handles.REbutton6,'Enable','off');
    end
elseif get(handles.OPT2,'Value')
    if iscellstr(get(handles.QUppmenu1,'String')) && ~CorrectionMode % you should have more than tree maps loaded
        if length(get(handles.QUppmenu1,'String')) >= 2
            set(handles.REbutton5,'Enable','on');
        else
            set(handles.REbutton5,'Enable','off');
        end
        if length(get(handles.QUppmenu1,'String')) >= 3
            set(handles.REbutton6,'Enable','on');
        else
            set(handles.REbutton6,'Enable','off');
        end
    else
        set(handles.REbutton5,'Enable','off');
        set(handles.REbutton6,'Enable','off');
    end
elseif get(handles.OPT3,'Value')
    if iscellstr(get(handles.REppmenu2,'String')) && ~CorrectionMode % you should have more than tree maps loaded
        if length(get(handles.REppmenu2,'String')) >= 2
            set(handles.REbutton5,'Enable','on');
        else
            set(handles.REbutton5,'Enable','off');
        end
        if length(get(handles.REppmenu2,'String')) >= 3
            set(handles.REbutton6,'Enable','on');
        else
            set(handles.REbutton6,'Enable','off');
        end
    else
        set(handles.REbutton5,'Enable','off');
        set(handles.REbutton6,'Enable','off');
    end
end
        
   

if CorrectionMode
    set(handles.Button2,'Enable','off');
    set(handles.Button1,'Enable','off');
    set(handles.Button4,'Enable','off');
    set(handles.ButtonSettings,'Enable','off');
    
    set(handles.ButtonSettings,'Enable','off');
    set(handles.AboutXMapTools,'Enable','off');
    set(handles.OPT1,'Enable','off');
    set(handles.OPT2,'Enable','off');
    set(handles.OPT3,'Enable','off');
    set(handles.MButton1,'Enable','off');
    
    set(handles.THppmenu1,'Enable','off');
    set(handles.THppmenu2,'Enable','off');
    set(handles.THppmenu3,'Enable','off');
    
    set(handles.THbutton2,'Enable','off');
    
else
    set(handles.Button2,'Enable','on');
    set(handles.Button1,'Enable','on');
    set(handles.Button4,'Enable','on');
    set(handles.ButtonSettings,'Enable','on');
    
    set(handles.ButtonSettings,'Enable','on');
    set(handles.AboutXMapTools,'Enable','on');
    set(handles.OPT1,'Enable','on');
    set(handles.OPT2,'Enable','on');
    set(handles.OPT3,'Enable','on');
    set(handles.MButton1,'Enable','on');
    
    set(handles.THppmenu1,'Enable','on');
    set(handles.THppmenu2,'Enable','on');
    set(handles.THppmenu3,'Enable','on');
    
    set(handles.THbutton2,'Enable','on');
end



return


% #########################################################################
%     GESTION D'AFFICHAGE

function AffOPT(Opt, hObject, eventdata, handles)
if Opt == 1 % XRay
    set(handles.OPT1,'Value',1);
    set(handles.OPT2,'Value',0);
    set(handles.OPT3,'Value',0);
    
    % Update
    %set(handles.PAN1,'Visible','off');
    %set(handles.PAN2,'Visible','off');
    %set(handles.PAN3,'Visible','off');
    
    % Update
    set(handles.PAN1a,'Visible','on');
    set(handles.PAN2a,'Visible','off');
    set(handles.PAN3a,'Visible','off');
    
    Data = handles.data;
    if length(Data.map) > 1
        set(handles.PPMenu1,'Value',1);
        PPMenu1_Callback(hObject, eventdata, handles);
    end
    
    % Menu
%     set(handles.MenXray,'enable','on');
%     set(handles.MenQuanti,'enable','off');
%     set(handles.MenResults,'enable','off');
end

if Opt == 2 % Quanti
    set(handles.OPT1,'Value',0);
    set(handles.OPT2,'Value',1);
    set(handles.OPT3,'Value',0);
    
    % Update
    %set(handles.PAN1,'Visible','off');
    %set(handles.PAN2,'Visible','off');
    %set(handles.PAN3,'Visible','off');
    
    % Update
    set(handles.PAN1a,'Visible','off');
    set(handles.PAN2a,'Visible','on');
    set(handles.PAN3a,'Visible','off');
    
    Quanti = handles.quanti; 
    if length(Quanti) > 1
        if get(handles.QUppmenu2,'Value') == 1
            set(handles.QUppmenu2,'Value',length(Quanti));
        end
        QUppmenu2_Callback(hObject, eventdata, handles);
    end
    
    % Menu
%     set(handles.MenXray,'enable','off');
%     set(handles.MenQuanti,'enable','on');
%     set(handles.MenResults,'enable','off');
end

if Opt == 3 % Results
    set(handles.OPT1,'Value',0);
    set(handles.OPT2,'Value',0);
    set(handles.OPT3,'Value',1);
    
    % Update
    %set(handles.PAN1,'Visible','off');
    %set(handles.PAN2,'Visible','off');
    %set(handles.PAN3,'Visible','on');
    
    % Update
    set(handles.PAN1a,'Visible','off');
    set(handles.PAN2a,'Visible','off');
    set(handles.PAN3a,'Visible','on');
    
    Results = handles.results;
    if length(Results)
        set(handles.REppmenu1,'Value', length(Results)+1);
        REppmenu1_Callback(hObject, eventdata, handles);
    end
    
    % Menu
%     set(handles.MenXray,'enable','off');
%     set(handles.MenQuanti,'enable','off');
%     set(handles.MenResults,'enable','on');
end

OnEstOu(hObject, eventdata, handles);
guidata(hObject, handles);
return


function OPT1_Callback(hObject, eventdata, handles)
Opt = 1;
AffOPT(Opt, hObject, eventdata, handles);
guidata(hObject, handles);
return


function OPT2_Callback(hObject, eventdata, handles)
Opt = 2;
AffOPT(Opt, hObject, eventdata, handles);
guidata(hObject, handles);
return


function OPT3_Callback(hObject, eventdata, handles)
Opt = 3;
AffOPT(Opt, hObject, eventdata, handles);
guidata(hObject, handles);
return


% #########################################################################
%     STYLE DES GRAPHS
function GraphStyle(hObject, eventdata, handles)
set(handles.axes1,'FontName','Times New Roman')
set(handles.axes2,'FontName','Times New Roman')
set(handles.axes2,'FontSize',10)


% we display a new graph and we delete the button to select/unselect points
% for the standardization.                         Pierre Lanari (26.04.13)
set(handles.PRButton6,'visible','off'); 

return
        

% #########################################################################
%     WAITBARPERSO - Used in the GUI (V1.6.2)
function WaitBarPerso(Percent, hObject, eventdata, handles)

LesValues = [0.03654485048338874 0.34090909090909094 0.7375415282392027 0.1818181818181818];
LaLong = LesValues(3) * (Percent + 0.0001);

LesValues(3) = LaLong;

set(handles.WaitBar1,'Visible','on');
set(handles.WaitBar2,'Visible','on');
set(handles.WaitBar3,'Visible','on');

set(handles.UiPanelScrollBar,'visible','on');

% Trace
set(handles.WaitBar3,'Position',LesValues)

if Percent == 0 % we display the image
    
    iconsFolder = fullfile(get(handles.PRAffichage0,'String'),'/Dev/img/');
    iconUrl = strrep([handles.FileDirCode, iconsFolder 'spinner.gif'],'\','/');

    str = ['<html><img src="' iconUrl '"/></html>'];
    
    set(handles.DispWait,'string',str,'visible','on');
    %jDispWait = findjobj(handles.DispWait);
    %handles.jDispWait.setContentAreaFilled(0);
    %handles.jDispWait.setBorder([]);
    
end


if Percent == 1 % on cache
    
    set(handles.UiPanelScrollBar,'visible','off');
    
    set(handles.WaitBar1,'Visible','off');
    set(handles.WaitBar2,'Visible','off');
    set(handles.WaitBar3,'Visible','off');
    
    str = [''];
    set(handles.DispWait,'string',str,'visible','off');
    
end

guidata(hObject, handles);
drawnow
return


% #########################################################################
%     TXT COLOR CONTROL
function TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles)

LaGoodColor = handles.TxtDatabase(CodeTxt(1)).Color(CodeTxt(2));
if LaGoodColor == 1
    set(handles.TxtControl,'ForegroundColor',[0,0,1])
end

if LaGoodColor == 2
    set(handles.TxtControl,'ForegroundColor',[0.847059,0.160784,0]) %red
end
  
return


% #########################################################################
%     MOUSEMOVE (NEW 1.6.2)
function mouseMove(hObject, eventdata) 
handles = guidata(hObject);

if ~handles.OptionPanelDisp & get(handles.DisplayCoordinates,'Value')

    laSize = size(XimrotateX(handles.data.map(1).values,handles.rotateFig));
    %keyboard

    lesX = [0 laSize(2)]; %get(handles.axes1,'XLim');
    lesY = [0 laSize(1)]; %get(handles.axes1,'YLim');

    xLength = lesX(2)-lesX(1);
    yLength = lesY(2)-lesY(1);

    C = get (handles.axes1, 'CurrentPoint');
    %title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']); 


    % - - - - - - - - - - - - - - - - - - - 
    lesInd = get(handles.axes1,'child');

    % On extrait l'image...
    for i=1:length(lesInd)
        leType = get(lesInd(i),'Type');
        if length(leType) == 5
            if leType == 'image';
                Data = get(lesInd(i),'CData');
            end
        end   
    end
    % - - - - - - - - - - - - - - - - - - - 


    if C(1,1) >= 0 && C(1,1) <= lesX(2) && C(1,2) >= 0 && C(1,2) <= lesY(2) && handles.HistogramMode == 0

        %keyboard
        set(gcf,'pointer','crosshair');

        switch handles.rotateFig

            case 0

                set(handles.text47, 'string', round(C(1,1))); %abscisse
                set(handles.text48, 'string', round(C(1,2))); %ordonnée

            case 90
                set(handles.text47, 'string', round(yLength - C(1,2))); %abscisse
                set(handles.text48, 'string', round(C(1,1))); %ordonnée

            case 180
                set(handles.text47, 'string', round(xLength - C(1,1))); %abscisse
                set(handles.text48, 'string', round(yLength - C(1,2))); %ordonnée

            case 270
                set(handles.text47, 'string', round(C(1,2))); %abscisse
                set(handles.text48, 'string', round(xLength - C(1,1))); %ordonnée            

        end

        % no rotation here because we read the map !!!

        TheX = round(C(1,2));
        TheY = round(C(1,1));

        if ~TheX, TheX = 1; end   % This is to fix a border error
        if ~TheY, TheY = 1; end

        TheZ = Data(TheX,TheY);
        if get(handles.OPT1,'value')
            TheZ = round(TheZ);
        end
        set(handles.text76, 'string', num2str(TheZ));




    else
        set(gcf,'pointer','arrow');
        set(handles.text47, 'string', '...'); %abscisse
        set(handles.text48, 'string', '...'); %ordonnée
        set(handles.text76, 'string', '...'); %value
    end
    
else
    set(gcf,'pointer','arrow');
    set(handles.text47, 'string', '...'); %abscisse
    set(handles.text48, 'string', '...'); %ordonnée
    set(handles.text76, 'string', '...'); %value
end
    
return


% #########################################################################
%     XMAPCOLORBAR (NEW 1.5.4)
function XMapColorbar(lesData,handles,Case)    
%
if Case == 1
    axes(handles.axes1);
end

Value = get(handles.checkbox1,'Value');
Value2 = get(handles.checkbox7,'Value');

TheCodeColorMap = get(handles.PopUpColormap,'String');
TheSelected = get(handles.PopUpColormap,'Value');

TheCode = TheCodeColorMap{TheSelected};

switch TheCode
    
    case 'Jet'
        if Value == 0 && Value2 == 0
            colormap([jet(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;jet(64)])
        elseif Value == 0 && Value2 == 1
            colormap([jet(64);0,0,0])
        else
            colormap([0,0,0;jet(64);0,0,0])
        end
    case 'Parula'
        if Value == 0 && Value2 == 0
            colormap([parula(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;parula(64)])
        elseif Value == 0 && Value2 == 1
            colormap([parula(64);0,0,0])
        else
            colormap([0,0,0;parula(64);0,0,0])
        end
    case 'WYRK'                                       % idea of Eric Lewin. 
        if Value == 0 && Value2 == 0
            colormap([handles.wyrk])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;handles.wyrk])
        elseif Value == 0 && Value2 == 1
            colormap([handles.wyrk;0,0,0])
        else
            colormap([0,0,0;handles.wyrk;0,0,0])
        end
    case 'HSV'
        if Value == 0 && Value2 == 0
            colormap([hsv(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;hsv(64)])
        elseif Value == 0 && Value2 == 1
            colormap([hsv(64);0,0,0])
        else
            colormap([0,0,0;hsv(64);0,0,0])
        end
        
    case 'Hot'
        if Value == 0 && Value2 == 0
            colormap([hot(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;hot(64)])
        elseif Value == 0 && Value2 == 1
            colormap([hot(64);0,0,0])
        else
            colormap([0,0,0;hot;0,0,0])
        end
    case 'Cool'
        if Value == 0 && Value2 == 0
            colormap([cool(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;cool(64)])
        elseif Value == 0 && Value2 == 1
            colormap([cool(64);0,0,0])
        else
            colormap([0,0,0;cool(64);0,0,0])
        end
    case 'Spring'
        if Value == 0 && Value2 == 0
            colormap([spring(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;spring(64)])
        elseif Value == 0 && Value2 == 1
            colormap([spring(64);0,0,0])
        else
            colormap([0,0,0;spring(64);0,0,0])
        end
    case 'Summer'
        if Value == 0 && Value2 == 0
            colormap([summer(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;summer(64)])
        elseif Value == 0 && Value2 == 1
            colormap([summer(64);0,0,0])
        else
            colormap([0,0,0;summer(64);0,0,0])
        end
    case 'Autumn'
        if Value == 0 && Value2 == 0
            colormap([autumn(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;autumn(64)])
        elseif Value == 0 && Value2 == 1
            colormap([autumn(64);0,0,0])
        else
            colormap([0,0,0;autumn(64);0,0,0])
        end
    case 'Winter'
        if Value == 0 && Value2 == 0
            colormap([winter(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;winter(64)])
        elseif Value == 0 && Value2 == 1
            colormap([winter(64);0,0,0])
        else
            colormap([0,0,0;winter(64);0,0,0])
        end
    case 'Gray'
        if Value == 0 && Value2 == 0
            colormap([gray(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;gray(64)])
        elseif Value == 0 && Value2 == 1
            colormap([gray(64);0,0,0])
        else
            colormap([0,0,0;gray(64);0,0,0])
        end
    case 'Bone'
        if Value == 0 && Value2 == 0
            colormap([bone(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;bone(64)])
        elseif Value == 0 && Value2 == 1
            colormap([bone(64);0,0,0])
        else
            colormap([0,0,0;bone(64);0,0,0])
        end
    case 'Copper'
        if Value == 0 && Value2 == 0
            colormap([copper(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;copper(64)])
        elseif Value == 0 && Value2 == 1
            colormap([copper(64);0,0,0])
        else
            colormap([0,0,0;copper(64);0,0,0])
        end
    case 'Pink'
        if Value == 0 && Value2 == 0
            colormap([pink(64)])
        elseif Value == 1 && Value2 == 0
            colormap([0,0,0;pink(64)])
        elseif Value == 0 && Value2 == 1
            colormap([pink(64);0,0,0])
        else
            colormap([0,0,0;pink(64);0,0,0])
        end
end

drawnow

    
%colorbar('delete'); 

%if size(lesData,2) > size(lesData,1)*1.3
%    colorbar('horizontal')
%else
%    colorbar('vertical')
%end

return


% #########################################################################
%    COORDINATES OF MAPS (FIG) FROM REF COORDINATES (NEW 1.6.2)
function [x,y] = CoordinatesFromRef(xref,yref,handles)
% This function transform the true coordinates (Xref,Yref) get from 
% XginputX into map coordinates (x,y) for display.
%
% This function use the variable handles.rotateFig to get the orientation
% of the current figure (case 0, 90, 180, 270). 
%
% P. Lanari (25.04.13)


laSize = size(XimrotateX(handles.data.map(1).values,handles.rotateFig));

lesX = [0 laSize(2)]; %get(handles.axes1,'XLim');
lesY = [0 laSize(1)]; %get(handles.axes1,'YLim');


xLengthFig = lesX(2)-lesX(1);          % FOR Yfig and Yfig (not Xref and Yref)
yLengthFig = lesY(2)-lesY(1);


switch handles.rotateFig
    
    case 0
        
        x = xref;
        y = yref;
        
    case 90
        
        x = yref;
        y = yLengthFig - xref;
        
    case 180
        
        x = xLengthFig - xref;
        y = yLengthFig - yref;
        
    case 270
        
        x = xLengthFig - yref;
        y = xref;
                  
end



return


% #########################################################################
%    COORDINATES OF REF FROM MAP (FIG) COORDINATES (NEW 1.6.2)
function [xref,yref] = CoordinatesFromFig(x,y,handles)
% This function transform the Fig coordinates (X,Y) get from 
% CoordinatesFromRef into Ref coordinates (Xref,YRef) for projectiob.
%
% This function use the variable handles.rotateFig to get the orientation
% of the current figure (case 0, 90, 180, 270). 
%
% P. Lanari (25.04.13)


laSize = size(XimrotateX(handles.data.map(1).values,handles.rotateFig));

lesX = [0 laSize(2)]; %get(handles.axes1,'XLim');
lesY = [0 laSize(1)]; %get(handles.axes1,'YLim');

xLengthFig = lesX(2)-lesX(1);
yLengthFig = lesY(2)-lesY(1);


switch handles.rotateFig
    
    case 0
        
        xref = x;
        yref = y;
        

    case 90
        
        xref = yLengthFig - y;
        yref = x;
        
        
    case 180
        
        xref = xLengthFig - x;
        yref = yLengthFig - y;
        
        
    case 270
        
        xref = y;
        yref = xLengthFig - x;
        
end
return
  

% #########################################################################
%    XimrotateX (NEW 1.6.3)
function [b] = XimrotateX(A,phi)
   
if phi == 0
    b = A;
elseif phi == 90
    b = rot90(A,1);
elseif phi == 180
    b = rot90(A,2);
elseif phi == 270
    b = rot90(A,3);
elseif phi == -90
    b = rot90(A,-1);
elseif phi == -180
    b = rot90(A,-2);
elseif phi == -270
    b = rot90(A,-3);
end
   
return




% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%                          CALLBACK FONCTIONS 
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


% -------------------------------------------------------------------------
% 1) DISPLAY FUNCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%     XRAY !! ELEMENT SELECTION FOR DISPLAY. V2.1.1
function PPMenu1_Callback(hObject, eventdata, handles)

Data = handles.data;
MaskFile = handles.MaskFile;

% Temporaire, prendre en compte le fait que l'on l'affiche...
set(handles.UiPanelMapInfo,'Visible','off');

%handles.currentdisplay = 1; % Input change
%set(handles.QUppmenu2,'Value',1); % Input Change
%set(handles.REppmenu1,'Value',1); % Input Change

% Display without median filter...
set(handles.FIGbutton1,'Value',0);

MaskSelected = get(handles.PPMenu3,'Value');
Selected = get(handles.PPMenu1,'Value');
Mineral = get(handles.PPMenu2,'Value');

ListElem = get(handles.PPMenu1,'String');
NameElem = ListElem(Selected);

if Mineral > 1
    RefMin = Mineral - 1;
    AAfficher = MaskFile(MaskSelected).Mask == RefMin;
    AAfficher = Data.map(Selected).values .* AAfficher;
    
else
    AAfficher = Data.map(Selected).values;
end

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    AAfficher = AAfficher.*handles.corrections(1).mask;
end

% Updated with image rotate (25.04.13)
set(gcf, 'WindowButtonMotionFcn', '');

cla(handles.axes1)
axes(handles.axes1), imagesc(XimrotateX(AAfficher,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]); 
XMapColorbar(AAfficher,handles,1);             % 1 is for axes1 (new 2.1.3)

zoom on                                                         % New 1.6.2

% Display coordinates new 1.5.4 (11.2012)
set(gcf, 'WindowButtonMotionFcn', @mouseMove);


CodeTxt = [3,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(NameElem)]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(3).txt(1)),' - ',char(NameElem)]); 

drawnow

Min = min(AAfficher(find(AAfficher(:) > 0)));
Max = max(AAfficher(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

if Max > Min
    caxis([Min Max]);
end

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%axes(handles.axes2), hist(AAfficher(find(AAfficher(:) ~= 0)),30)

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     XRAY !! SELECT A MINERAL (V2.1.1)
function PPMenu2_Callback(hObject, eventdata, handles)

PPMenu1_Callback(hObject, eventdata, handles) 
% Update 2.1.1 - should work...


% Data = handles.data; 
% MaskFile = handles.MaskFile; 
% 
% %handles.currentdisplay = 1; % Input change
% %set(handles.QUppmenu2,'Value',1); % Input Change
% %set(handles.REppmenu1,'Value',1); % Input Change
% 
% set(handles.FIGbutton1,'Value',0);
% 
% % Display without median filter...
% set(handles.FIGbutton1,'Value',0);
% 
% MaskSelected = get(handles.PPMenu3,'Value');
% Selected = get(handles.PPMenu1,'Value');
% Mineral = get(hObject,'Value');
% Value = get(handles.checkbox1,'Value');
% 
% if Mineral > 1
%     RefMin = Mineral - 1;
%     AAfficher = MaskFile(MaskSelected).Mask == RefMin;
%     AAfficher = Data.map(Selected).values .* AAfficher;
%     
%     % Updated with image rotate (25.04.13)
%     cla(handles.axes1)
%     axes(handles.axes1)
%     imagesc(XimrotateX(AAfficher,handles.rotateFig)), axis image, colorbar('vertical')     % Updated 1.6.2
%     set(handles.axes1,'xtick',[], 'ytick',[]); 
%     XMapColorbar(AAfficher,handles)
%     
%     zoom on                                                         % New 1.6.2
%     
%     Min = min(AAfficher(find(AAfficher>=1)));
%     Max = max(max(AAfficher));
%     set(handles.ColorMax,'String',Max);
%     set(handles.ColorMin,'String',Min);
%     set(handles.FilterMin,'String',Min);
%     set(handles.FilterMax,'String',Max);
%     
%     if Max > Min
%         caxis([Min Max]);
%     end
%     
% %     if Value == 1
% %         colormap([0,0,0;jet(64)])
% %     else
% %         colormap([jet(64)])
% %     end
%     
%     cla(handles.axes2)
%     axes(handles.axes2), hist(AAfficher(find(AAfficher(:) ~= 0)),30)
%     
% else
%     Max = max(max(Data.map(Selected).values));
%     Min = min(min(Data.map(Selected).values));
%     
%     % Updated with image rotate (25.04.13)
%     cla(handles.axes1)
%     axes(handles.axes1)
%     imagesc(XimrotateX(Data.map(Selected).values,handles.rotateFig)), axis image, colorbar('vertical')    % Updated 1.6.2
%     set(handles.axes1,'xtick',[], 'ytick',[]); 
%     XMapColorbar(Data.map(Selected).values,handles)
%     
%     zoom on                                                         % New 1.6.2
%     
%     if Max > Min
%         caxis([Min,Max]);
%     end
% %     if Value == 1
% %         colormap([0,0,0;jet(64)])
% %     else
% %         colormap([jet(64)])
% %     end
%     
%     cla(handles.axes2)
%     axes(handles.axes2), hist(Data.map(Selected).values(find(Data.map(Selected).values(:) ~= 0)),30)
% end
% 
% GraphStyle(hObject, eventdata, handles)
% guidata(hObject, handles);
% OnEstOu(hObject, eventdata, handles);

return


% #########################################################################
%     XRAY !! SEE THE MASKS (V2.1.1)
function MaskButton2_Callback(hObject, eventdata, handles)
%

NumMask = get(handles.PPMenu3,'Value');
Liste = get(handles.PPMenu3,'String');
Name = Liste(NumMask);

MaskFile = handles.MaskFile;

Mask4Display = MaskFile(NumMask).Mask;
NbMask = MaskFile(NumMask).Nb;
NameMask = MaskFile(NumMask).NameMinerals;

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    Mask4Display = Mask4Display.*handles.corrections(1).mask;
end

% Updated with image rotate (25.04.13)
set(gcf, 'WindowButtonMotionFcn', '');
cla(handles.axes1)
axes(handles.axes1)
imagesc(XimrotateX(Mask4Display,handles.rotateFig)), axis image, % update 1.6.2
set(handles.axes1,'xtick',[], 'ytick',[]); 

zoom on                                                         % New 1.6.2

set(gcf, 'WindowButtonMotionFcn', @mouseMove);

if get(handles.CorrButtonBRC,'Value')
    colormap([0,0,0;hsv(NbMask)])
    hcb = colorbar('YTickLabel',NameMask); caxis([0 NbMask+1]);
    set(hcb,'YTickMode','manual','YTick',[0.5:1:NbMask+1]);
else
    colormap(hsv(NbMask))
    hcb = colorbar('YTickLabel',NameMask(2:end)); caxis([1 NbMask+1]);
    set(hcb,'YTickMode','manual','YTick',[1.5:1:NbMask+1]);
end

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2)
%axes(handles.axes2), hist(Mask4Display(find(Mask4Display(:)~=0)),30)

CodeTxt = [7,8];
set(handles.TxtControl,'String',[char(Name),' ',char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[,char(Name),' ',char(handles.TxtDatabase(7).txt(8))]);

GraphStyle(hObject, eventdata, handles)
guidata(hObject, handles);
return


% #########################################################################
%     XRAY !! DISPLAY PROFILS POINTS INTO THE MAP (V1.6.2)
function PRButton3_Callback(hObject, eventdata, handles)

Profils = handles.profils;

axes(handles.axes1), hold on

xref = Profils.idxallpr(:,1);
yref = Profils.idxallpr(:,2);

[x,y] = CoordinatesFromRef(xref,yref,handles);


hold on
for i=1:length(Profils.pointselected)
    if Profils.pointselected(i)
        plot(x(i),y(i),'+k')
        plot(x(i),y(i),'om','markersize',4,'LineWidth',2)
    else
        plot(x(i),y(i),'+k')
        plot(x(i),y(i),'ok','markersize',4,'LineWidth',2)
    end
end

set(handles.axes1,'xtick',[], 'ytick',[]); 

set(handles.PRButton6,'visible','on','enable','on');                          % New 1.6.2

guidata(hObject,handles);
return


% #########################################################################
%     XRAY !! HIDE PROFILS POINTS FROM THE MAP V1.4.1
function PRButton4_Callback(hObject, eventdata, handles)
lesInd = get(handles.axes1,'child');

% On retrouve la carte et on l'affiche...
% Elle va se mettre dessus, mais ça ne pose pas de problèmes pour
% l'export... car on a deux fois la même carte...

axes(handles.axes1)
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 5
        if leType == 'image';
            AAfficher = get(lesInd(i),'CData');
        end
    end 
end

% New 2.1.1  -  fix up the problem of serious lags...
axes(handles.axes1)
cla
imagesc(AAfficher), axis image
set(handles.axes1,'xtick',[], 'ytick',[]); 
%XMapColorbar(get(lesInd(i),'CData'),handles);
zoom on  
                                                       
set(handles.PRButton6,'visible','off');                         % New 1.6.2

guidata(hObject,handles);
return


% #########################################################################
%     QUANTI !! OXIDE W PERCENT LIST (V1.6.2)
function QUppmenu1_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

set(handles.FIGbutton1,'Value',0); % medfilter

ValMin = get(handles.QUppmenu2,'Value');
AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);

ValOxi = get(handles.QUppmenu1,'Value');
AllOxi = get(handles.QUppmenu1,'String');

CodeTxt = [3,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(SelMin),' - ',char(AllOxi(ValOxi))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(3).txt(2)),' - ',char(AllMin(ValMin)),' - ',char(AllOxi(ValOxi))]); 
%drawnow

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(XimrotateX(Quanti(ValMin).elem(ValOxi).quanti,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]);
XMapColorbar(Quanti(ValMin).elem(ValOxi).quanti,handles,1)

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(Quanti(ValMin).elem(ValOxi).quanti(find(Quanti(ValMin).elem(ValOxi).quanti(:) ~= 0)),30)

AADonnees = Quanti(ValMin).elem(ValOxi).quanti(:);
Min = min(AADonnees(find(AADonnees(:) > 0)));
Max = max(AADonnees(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');

% Les 4 lignes ci-dessous provoquent des lags sur ma version... 
axes(handles.axes1);
if Max > Min
    caxis([Min,Max]);
end

% if Value == 1
% 	colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
return


% #########################################################################
%     QUANTI !! MINERAL LIST (FOR OX%) (V1.6.2)
function QUppmenu2_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

set(handles.FIGbutton1,'Value',0); % medianfilter = 0;

ValMin = get(handles.QUppmenu2,'Value');
if ValMin == 1, % verif
    OnEstOu(hObject, eventdata, handles)
    return 
end

AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);

% First element is automaticaly selected if it's possible (NEW 1.6.1
% 28/12/12)
ancOxiListe = get(handles.QUppmenu1,'String');
ancOxi = ancOxiListe(get(handles.QUppmenu1,'Value'));

newOxiListe = Quanti(ValMin).listname;

indInNewOxiListe = ismember(newOxiListe,ancOxi);
if sum(indInNewOxiListe) == 1
    ValOxi = find(indInNewOxiListe);
else
    ValOxi = 1;
end        
%keyboard
set(handles.QUppmenu1,'String',Quanti(ValMin).listname);
set(handles.QUppmenu1,'Value',ValOxi);
AllOxi = get(handles.QUppmenu1,'String');

CodeTxt = [3,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(SelMin),' - ',char(AllOxi(ValOxi))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(3).txt(2)),' - ',char(AllMin(ValMin)),' - ',char(AllOxi(ValOxi))]); 
drawnow


set(handles.QUtexte1,'String',strcat(num2str(Quanti(ValMin).nbpoints),' pts'));

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(XimrotateX(Quanti(ValMin).elem(ValOxi).quanti,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]);
XMapColorbar(Quanti(ValMin).elem(ValOxi).quanti,handles,1)

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(Quanti(ValMin).elem(ValOxi).quanti(find(Quanti(ValMin).elem(ValOxi).quanti(:) ~= 0)),30)

AADonnees = Quanti(ValMin).elem(ValOxi).quanti(:);
Min = min(AADonnees(find(AADonnees(:) > 0)));
Max = max(AADonnees(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');

% Attention, les 4 lignes ci-dessous semblent provoquer des lags.. 
axes(handles.axes1);
if Max > Min
    caxis([Min,Max]);
end


% if Value == 1
% 	colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
set(handles.axes1,'xtick',[], 'ytick',[]); 
return


% #########################################################################
%     QUANTI !! OXIDE W PERCENT SUM (button) (V1.6.2)
function QUbutton3_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

% median filter = 0;
set(handles.FIGbutton1,'Value',0);

ValMin = get(handles.QUppmenu2,'Value');
AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);

lesOxi = get(handles.QUppmenu1,'String');

% SUM
SumValue = zeros(size(Quanti(ValMin).elem(1).quanti));
for i=1:length(lesOxi);
    SumValue = SumValue + Quanti(ValMin).elem(i).quanti;
end

CodeTxt = [3,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(SelMin),' - Oxide Sum']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

cla(handles.axes1)
axes(handles.axes1)
imagesc(XimrotateX(SumValue,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]); 
XMapColorbar(SumValue,handles,1)

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%axes(handles.axes2), hist(SumValue(find(SumValue ~= 0)),30)

AADonnees = SumValue;
Min = min(AADonnees(find(AADonnees(:) > 0)));
Max = max(AADonnees(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');
% axes(handles.axes1);
% if Max > Min
%     caxis([Min,Max]);
% end
% if Value == 1
% 	colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
return


% #########################################################################
%     RESULTS !! DISPLAY RESULTS (CHOICE OF THERMOMETER) (V1.6.2)
function REppmenu1_Callback(hObject, eventdata, handles)

Results = handles.results;

% Median filter
set(handles.FIGbutton1,'Value',0);
   
Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none$
if Onest < 1
    OnEstOu(hObject, eventdata, handles)
    return
end
Onaff = 1; % for good transition
    
set(handles.REppmenu2,'String',Results(Onest).labels);
set(handles.REppmenu2,'Value',Onaff);

REppmenu2_Callback(hObject, eventdata, handles);

guidata(hObject,handles);

GraphStyle(hObject, eventdata, handles)
OnEstOu(hObject, eventdata, handles)
return


% #########################################################################
%     RESULTS !! DISPLAY RESULTS (CHOICE OF VARIABLE - T - P ...) (V1.6.2)
function REppmenu2_Callback(hObject, eventdata, handles)

% ---------- Display mode 3 ---------- 
Results = handles.results;

% median filter
set(handles.FIGbutton1,'Value',0);
   
Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none$
if Onest == 0
    return
end
Onaff = get(handles.REppmenu2,'Value');

ListResult = get(handles.REppmenu1,'String');
ListDispl = get(handles.REppmenu2,'String');

CodeTxt = [3,3];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(ListResult(Onest+1)),' - ',char(ListDispl(Onaff))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(3).txt(3)),' - ',char(ListResult(Onest+1)),' - ',char(ListDispl(Onaff))]);

AAfficher = reshape(Results(Onest).values(:,Onaff),Results(Onest).reshape(1),Results(Onest).reshape(2));

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(XimrotateX(AAfficher,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]);
XMapColorbar(AAfficher,handles,1)

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(AAfficher(find(AAfficher(:) ~= 0)),30)

Min = min(AAfficher(find(AAfficher(:) > 0)));
Max = max(AAfficher(:));
    
if length(Min) < 1
	Min = Max;
end
    
set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');

% Attention, les 4 lignes suivantes font des lags sur ma version.

axes(handles.axes1);
if Max > Min
	caxis([Min,Max]);
end

% if Value == 1
%     colormap([0,0,0;jet(64)])
% else
% 	colormap([jet(64)])
% end

guidata(hObject,handles);
GraphStyle(hObject, eventdata, handles)
return




% -------------------------------------------------------------------------
% 2.1) DISPLAY OPTIONS
% -------------------------------------------------------------------------


% #########################################################################
%     EXPORT2 (V2.1.1)
function ExportWindow_Callback(hObject, eventdata, handles)

% La maintenant la grande question est comment récupérer la colorbar
axes(handles.axes1)
CMap = colormap;

lesInd = get(handles.axes1,'child');

CLim = get(handles.axes1,'CLim');
YDir = get(handles.axes1,'YDir');


% This part has been removed (bug of display two colorbars)   version 1.6.2
% Noms de la colorbar (masques) 

%LesLabs = get(colorbar,'YTickLabel');
%LesMods = get(colorbar,'YTickMode');
%LesTics = get(colorbar,'YTick');
 

figure, 
hold on

% On trace d'abord les images...
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 5
        if leType == 'image';
            imagesc(get(lesInd(i),'CData')), axis image
        end
    end
    
end


% ensuite les lignes
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 4
        if leType == 'line';
            plot(get(lesInd(i),'XData'),get(lesInd(i),'YData'),'Marker',get(lesInd(i),'Marker'),'Color',get(lesInd(i),'Color'),'LineStyle',get(lesInd(i),'LineStyle'),'LineWidth',get(lesInd(i),'LineWidth'), ...
                'MarkerEdgeColor',get(lesInd(i),'MarkerEdgeColor'),'MarkerFaceColor',get(lesInd(i),'MarkerFaceColor'),'Markersize',get(lesInd(i),'MarkerSize')) % prpoprietés ici
        end
    end
    
end

% puis les textes
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 4
        if leType == 'text'
            LaPosition = get(lesInd(i),'Position');
            LeTxt = text(LaPosition(1),LaPosition(2),get(lesInd(i),'String'));
            set(LeTxt,'Color',get(lesInd(i),'Color'),'BackgroundColor',get(lesInd(i),'BackgroundColor'), ...
                'FontName',get(lesInd(i),'FontName'),'FontSize',get(lesInd(i),'FontSize'));
        end
    end
end

set(gca,'CLim',CLim);
set(gca,'YDir',YDir);
set(gca,'xtick',[], 'ytick',[]);
set(gca,'box','on')
set(gca,'LineStyleOrder','-')
set(gca,'LineWidth',0.5)

% Scale bar VER_XMapTools_750 2.1.1
LimitsMap = axis;

if LimitsMap(2) > 200

    plot([20 120],[LimitsMap(4)+40 LimitsMap(4)+40],'-k','linewidth',4);

    text(40,LimitsMap(4)+20,'100 px')

    if LimitsMap(2) > 350
        text(140,LimitsMap(4)+18,'XMapTools')
        text(140,LimitsMap(4)+42,datestr(clock))
    else
        %text(140,LimitsMap(4)+30,'VER_XMapTools_750')
    end

    plot([LimitsMap(1),LimitsMap(2)],[LimitsMap(4),LimitsMap(4)],'k','linewidth',1);
    plot([LimitsMap(1),LimitsMap(2)],[LimitsMap(3),LimitsMap(3)],'k','linewidth',1);

    axis([LimitsMap(1) LimitsMap(2) LimitsMap(3) LimitsMap(4)+60]);
end

colormap(CMap)
colorbar vertical

% This part has been removed (bug of display two colorbars)   version 1.6.2
%if length(LesMods) == 6 % manual
%    set(colorbar,'YTickLabel',LesLabs,'YTickMode',LesMods,'YTick',LesTics);
%end

%GraphStyle(hObject, eventdata, handles)
return


% #########################################################################
%     SELECT THE MIN COLORBAR VALUE V1.4.1
function ColorMin_Callback(hObject, eventdata, handles)
axes(handles.axes1),
Max = str2num(get(handles.ColorMax,'String'));
Min = str2num(get(handles.ColorMin,'String'));

if Min < Max
    caxis([Min Max]);
else
    CodeTxt = [6,1];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(6).txt(1))])
end

set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

handles.AutoContrastActiv = 0;

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     SELECT THE MAX COLORBAR VALUE V1.4.1
function ColorMax_Callback(hObject, eventdata, handles)
axes(handles.axes1),
Max = str2num(get(handles.ColorMax,'String'));
Min = str2num(get(handles.ColorMin,'String'));

if Max > Min
    caxis([Min,Max]);
else
    CodeTxt = [6,1];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(6).txt(1))])
end

set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

handles.AutoContrastActiv = 0;

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     PHASE SEPARATOR SETTING V1.4.1
function checkbox1_Callback(hObject, eventdata, handles)

% We only call the new update general function             % Changed 2.1.1
XMapColorbar([],handles,1);
    
% Value = get(handles.checkbox1,'Value');
% 
% Value2 = get(handles.checkbox7,'Value');
% 
% axes(handles.axes1)
% 
% 
% if Value == 1
%     
%     if Value2 == 1
%         colormap([0,0,0;jet(64);0,0,0])
%     else
%         colormap([0,0,0;jet(64)])
%     end
%     
% %     axes(handles.axes2)
% %     Max = str2num(get(handles.ColorMax,'String'));
% %     Min = str2num(get(handles.ColorMin,'String'));
% %     xlim([Min Max]), ylim('auto')
%     
% else
%     colormap([jet(64)])
%     set(handles.checkbox7,'Value',0);
%     
% %     axes(handles.axes2)
% %     xlim('auto'), ylim('auto')
% end

% guidata(hObject, handles);
return


% #########################################################################
%     PHASE SEPARATOR MAX BUTTON V1.5.1
function checkbox7_Callback(hObject, eventdata, handles)
%
% We only call the new update general function             % Changed 2.1.1
XMapColorbar([],handles,1);

% Value = get(handles.checkbox7,'Value');
% if Value ==1
%     set(handles.checkbox1,'Value',1);
% end
% 
% checkbox1_Callback(hObject, eventdata, handles);


return
    

% #########################################################################
%     AUTO LEVELS  V1.5.1
function ColorButton1_Callback(hObject, eventdata, handles)
%
lesInd = get(handles.axes1,'child');
ACA = handles.AutoContrastActiv;

if ACA
    % Reset Auto-contrast
    
    for i=1:length(lesInd)
        if length(get(lesInd(i),'type')) == 5 % image
            AADonnees = get(lesInd(i),'CData');
            break
        else
            AADonnees = [];
        end    
    end

    Min = min(AADonnees(find(AADonnees(:) > 0)));
    Max = max(AADonnees(:));

    set(handles.ColorMin,'String',Min);
    set(handles.ColorMax,'String',Max);
    set(handles.FilterMin,'String',Min);
    set(handles.FilterMax,'String',Max);

    axes(handles.axes1);
    if Max > Min
        caxis([Min Max]);
    end
    
    handles.AutoContrastActiv = 0;
    
    
else
    % Temporairement, on va bosser que sur le premier chlid qui est forcement
    % la carte. 

    for i=1:length(lesInd)
        if length(get(lesInd(i),'type')) == 5 % image 
            AADonnees = get(lesInd(i),'CData');
            break
        else
            AADonnees = [];
        end
    end

    Triee = sort(AADonnees(:));
    for i=1:length(Triee)
        if Triee(i) > 0 % defined
            break 
        end
    end
    NTriee = Triee(i:end);

    Val = round(length(NTriee) * 0.065); % voir avec une detection du pic.

    axes(handles.axes1)
    if Val > 1
        if NTriee(Val) < NTriee(length(NTriee)-Val)
            % V1.4.2 sans caxis
            set(handles.axes1,'CLim',[NTriee(Val),NTriee(length(NTriee)-Val)])
            %caxis([NTriee(Val),NTriee(length(NTriee)-Val)]);
        end
    else
        return % no posibility to update (size  = 0)
    end

    set(handles.ColorMax,'String',num2str(NTriee(length(NTriee)-Val)));
    set(handles.ColorMin,'String',num2str(NTriee(Val)));
    set(handles.FilterMax,'String',num2str(NTriee(length(NTriee)-Val)));
    set(handles.FilterMin,'String',num2str(NTriee(Val)));

    guidata(hObject,handles);
    
    handles.AutoContrastActiv = 1;

end


guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     MEDIAN FILTER (V1.6.2)
function FIGbutton1_Callback(hObject, eventdata, handles)
%ValueMedian = get(handles.FIGbutton1,'Value');
MedianSize = str2num(get(handles.FIGtext1,'String'));
lesInd = get(handles.axes1,'child');

if ~handles.MedianFilterActiv
    
    for i=1:length(lesInd);
        if length(get(lesInd(i),'type')) == 5 % image 
            AADonnees = get(lesInd(i),'CData');
            break
        else
            AADonnees = [];
        end
    end
    
    data2Image = XMapTools_medfilt2(AADonnees,[MedianSize,MedianSize],hObject, eventdata, handles);
    
    cla(handles.axes1,'reset');
    axes(handles.axes1)
    imagesc(data2Image), axis image, colorbar('vertical')
    set(handles.axes1,'xtick',[], 'ytick',[]); 
    XMapColorbar(AADonnees,handles,1)
    
    Max = str2num(get(handles.ColorMax,'String'));
    Min = str2num(get(handles.ColorMin,'String'));

    if Max > Min
        caxis([Min,Max]);
    end
    
%     Value = get(handles.checkbox1,'Value');
%     if Value == 1
%         colormap([0,0,0;jet(64)])
%     else
%         colormap([jet(64)])
%     end

    handles.medAff = AADonnees;
    handles.MedianFilterActiv = 1;
    
else % Cancel median filter (simple storage variable). 
    AADonnees = handles.medAff;
    cla(handles.axes1,'reset');
    axes(handles.axes1)
    
    imagesc(AADonnees), axis image, colorbar('vertical')
    set(handles.axes1,'xtick',[], 'ytick',[]); 
    XMapColorbar(AADonnees,handles,1)
    
    Max = str2num(get(handles.ColorMax,'String'));
    Min = str2num(get(handles.ColorMin,'String'));

    if Max > Min
        caxis([Min,Max]);
    end
    
%     Value = get(handles.checkbox1,'Value');
%     if Value == 1
%         colormap([0,0,0;jet(64)])
%     else
%         colormap([jet(64)])
%     end
    handles.MedianFilterActiv = 0;
end

zoom on                                                         % New 1.6.2

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);

return


% #########################################################################
%     ROTATE FIGURE (NEW V1.6.2)
function RotateButton_Callback(hObject, eventdata, handles)

previousRotate = handles.rotateFig;
    
handles.rotateFig = handles.rotateFig + 90;
if handles.rotateFig >= 360
    handles.rotateFig = 0;
end 

lesInd = get(handles.axes1,'child');

for i=1:length(lesInd);
    if length(get(lesInd(i),'type')) == 5 % image 
        AADonnees = get(lesInd(i),'CData');
        break
    else
        AADonnees = [];
    end
end

OrignalDonnes = XimrotateX(AADonnees,-previousRotate);    
% this is the right way (don't just turn of 90°)



axes(handles.axes1);
cla(handles.axes1,'reset');
imagesc(XimrotateX(OrignalDonnes,handles.rotateFig)), axis image, colorbar('vertical') 
set(handles.axes1,'xtick',[], 'ytick',[]); 
XMapColorbar(AADonnees,handles,1)


Max = str2num(get(handles.ColorMax,'String'));
Min = str2num(get(handles.ColorMin,'String'));

if Max > Min
    caxis([Min,Max]);
end

% Value = get(handles.checkbox1,'Value');
% if Value == 1
%     colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

zoom on                                                         % New 1.6.2
zoom reset                                % set the current view as default

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);


return


% #########################################################################
%     MEDIAN FUNCTION (V1.6.2)
function [Data] = XMapTools_medfilt2(AADonnees,MedSize,hObject, eventdata, handles)

% Modified function 'mediannan.m' from Bruno Luong (MATLAB Newsgroup)
% P. LANARI, 24/04/13

A = AADonnees;
sz = MedSize;

WaitBarPerso(0, hObject, eventdata, handles);
%drawnow

margin=(sz-1);%/2;
AA = nan(size(A)+2*margin);
AA(1+margin(1):end-margin(1),1+margin(2):end-margin(2))=A;
[iB jB]=ndgrid(1:sz(1),1:sz(2));
is=sub2ind(size(AA),iB,jB);
[iA jA] = ndgrid(1:size(A,1),1:size(A,2));
iA = sub2ind(size(AA),iA,jA);

WaitBarPerso(0.33, hObject, eventdata, handles);

iA = uint32(iA(:).');
iS = uint32(is(:)-1);
idx = bsxfun(@plus,iA,iS);
% idx = repmat(iA(:).',numel(is),1) + repmat(is(:)-1,1,numel(iA));

WaitBarPerso(0.55, hObject, eventdata, handles);

B = sort(AA(idx),1);
clear idx
j = any(isnan(B),1);
last = zeros(1,size(B,2))+size(B,1);
[trash last(j)]=max(isnan(B(:,j)),[],1);
last(j)=last(j)-1;

WaitBarPerso(0.75, hObject, eventdata, handles);

M = nan(1,size(B,2));
valid = find(~isnan(A(:).')); % <- Simple check on A
mid = (last(valid)+1)/2;
i1 = sub2ind(size(B),floor(mid),valid);
i2 = sub2ind(size(B),ceil(mid),valid);
M(valid) = 0.5*(B(i1) + B(i2));
M = reshape(M,size(A));

Data = M;

WaitBarPerso(1, hObject, eventdata, handles);

% Old LOOP version:
%     
% % here this is not possible to use non-square sizes...
% medianSize = MedSize(1);
% decalSize = medianSize-1;                 % number of pixe before and after    
% 
% % EXAMPLE: 
% %     medianSize = 2;     decalSize = 1;            Ok Center Ok
% %     medianSize = 3;     decalSize = 2;        Ok  Ok Center Ok  Ok
% %     medianSize = 4;     decalSize = 3;    Ok  Ok  Ok Center Ok  Ok  Ok
% %     ...
% 
% nbLin = size(AADonnees,1);
% nbCol = size(AADonnees,2);
% 
% Data = zeros(size(AADonnees));
% 
% WaitBarPerso(0, hObject, eventdata, handles);
% drawnow
% 
% compt = 0;
% for i=(decalSize+1):(nbCol-decalSize-1)
%     compt = compt+1;
%     if compt == 50
%         compt = 0;
%         WaitBarPerso(i/nbCol, hObject, eventdata, handles);
%         drawnow
%     end
%     
%     for j=(decalSize+1):(nbLin-decalSize-1)
%         
%         smallMatrix = AADonnees(j-decalSize:j+decalSize,i-decalSize:i+decalSize);
%         valMean = mean(smallMatrix(find(smallMatrix)));
%         if AADonnees(j,i) > 0 && valMean > 0
%             Data(j,i) = valMean;
%         else
%             Data(j,i) = 0;
%         end
%     end
% end
% 
% WaitBarPerso(1, hObject, eventdata, handles);
% drawnow



return


% #########################################################################
%     MEDIAN VALUE (V1.6.2)
function FIGtext1_Callback(hObject, eventdata, handles)
ValueMedian = get(handles.FIGbutton1,'Value');
MedianSize = str2num(get(handles.FIGtext1,'String'));
lesInd = get(handles.axes1,'child');

if ValueMedian == 1 % alors il faut changer...
    AADonnees = handles.medAff;
    cla(handles.axes1,'reset');
    axes(handles.axes1)
    data2Image = XMapTools_medfilt2(AADonnees,[MedianSize,MedianSize],hObject, eventdata, handles);
    imagesc(data2Image), axis image, colorbar('vertical')
    zoom on                                                         % New 1.6.2
    %imagesc(medfilt2(AADonnees,[MedianSize,MedianSize])), axis image, 
    
    set(handles.axes1,'xtick',[], 'ytick',[]); 
    
     
    Max = str2num(get(handles.ColorMax,'String'));
    Min = str2num(get(handles.ColorMin,'String'));

    if Max > Min
        caxis([Min,Max]);
    end
    
    XMapColorbar(AADonnees,handles,1)
    
%     Value = get(handles.checkbox1,'Value');
%     if Value == 1
%         colormap([0,0,0;jet(64)])
%     else
%         colormap([jet(64)])
%     end
else % on attend de cliquer pour faire un filtre...
    return
end
    
GraphStyle(hObject, eventdata, handles)
% FIGbutton1_Callback(hObject, eventdata, handles);
return


% #########################################################################
%     SAMPLING BUTTON 3 (NEW V1.4.1)
function BUsampling3_Callback(hObject, eventdata, handles)
Sampling(hObject, eventdata, handles, 3);
return
    
    
% #########################################################################
%     SAMPLING BUTTON 2 (NEW V1.4.1)
function BUsampling2_Callback(hObject, eventdata, handles)
Sampling(hObject, eventdata, handles, 2);
return


% #########################################################################
%     SAMPLING FUNCTION (V1.6.2)
function Sampling(hObject, eventdata, handles, Type)
% Recuperer les data
axes(handles.axes1)
lesInd = get(handles.axes1,'child');

% On extrait l'image...
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 5
        if leType == 'image';
            Data = get(lesInd(i),'CData');
        end
    end   
end

if length(Data(1,:)) > 700
    Decal(1) = 20;
elseif length(Data(1,:)) > 400
    Decal(1) = 10;
else
    Decal(1) = 5;
end

if length(Data(:,1)) > 700
    Decal(2) = 20;
elseif length(Data(:,1)) > 400
    Decal(2) = 10;
else
    Decal(2) = 5;
end


if Type == 1 % point
    
    CodeTxt = [12,1];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
%     set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(1))]);
    
    Clique = 1;
    Compt = 0;
    while Clique <= 2
        [Xref,Yref,Clique] = XginputX(1,handles);
        [X,Y] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
        if Clique <= 2
            Compt = Compt + 1;
            X = round(X);
            Y = round(Y);
            set(handles.SamplingDisplay,'String',num2str(Data(Y,X),3));
            LesData(Compt,2) = Data(Y,X);
            LesData(Compt,1) = Compt;
            axes(handles.axes1)
            leTxt = text(X-Decal(1),Y-Decal(2),num2str(Compt));
            set(leTxt,'backgroundcolor',[1,1,1],'Color',[0,0,0],'FontName','Times New Roman','FontSize',10)

            hold on, plot(X,Y,'o','MarkerEdgeColor','r','MarkerFaceColor','w')
        else
            if Compt == 0
                CodeTxt = [12,2];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
                % set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(2))]);
                return
            end

            set(handles.SamplingDisplay,'String','');
            figure, plot(LesData(:,1),LesData(:,2),'o-k')
            break
        end
    end

    set(handles.axes1,'xtick',[], 'ytick',[]);
    GraphStyle(hObject, eventdata, handles)
    
    
elseif Type == 2 % line
    
    for i=1:2
        if i ==1
            CodeTxt = [12,3];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(3))]);
        else
            CodeTxt = [12,4];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(4))]);
        end
        [Xref,Yref,Clique] = XginputX(1,handles);
        [X(i),Y(i)] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
        X(i) = round(X(i));
        Y(i) = round(Y(i));
        axes(handles.axes1)
        leTxt = text(X(i)-Decal(1),Y(i)-Decal(2),num2str(i));
        set(leTxt,'backgroundcolor',[1,1,1],'Color',[0,0,0],'FontName','Times New Roman','FontSize',10)
        hold on, plot(X(i),Y(i),'o','MarkerEdgeColor','r','MarkerFaceColor','w')
    end
    
    %plot(X,Y,'-w','linewidth',2)
    
    LX = max(X) - min(X);
    LY = max(Y) - min(Y);
    
    LZ = round(sqrt(LX^2 + LY^2));
    
    
    if X(2) > X(1)
        LesX = X(1):(X(2)-X(1))/(LZ-1):X(2);
    elseif X(2) < X(1)
        LesX = X(1):-(X(1)-X(2))/(LZ-1):X(2);
    else
        LesX = ones(LZ,1) * X(1);
    end
    
    if Y(2) > Y(1)
        LesY = Y(1):(Y(2)-Y(1))/(LZ-1):Y(2);
    elseif Y(2) < Y(1)
        LesY = Y(1):-(Y(1)-Y(2))/(LZ-1):Y(2);
    else
        LesY = ones(LZ,1) * Y(1);
    end
        
    plot(LesX,LesY,'.w','markersize',1);
    
    % Indexation 
    XCoo = 1:1:length(Data(1,:));
    YCoo = 1:1:length(Data(:,1));

    for i = 1 : length(LesX)
    	[V(i,1), IdxAll(i,1)] = min(abs(XCoo-LesX(i))); % Index X
    	[V(i,2), IdxAll(i,2)] = min(abs(YCoo-LesY(i))); % Index Y
    end

    plot(IdxAll(:,1),IdxAll(:,2),'.w','markersize',1);
    
    for i=1:length(IdxAll(:,1)) % Quanti
        LesData(i,1) = i;
        LesData(i,2) = Data(IdxAll(i,2),IdxAll(i,1));
        if LesData(i,2) == 0
            LesData(i,2) = NaN;
        end
    end
    
    figure, plot(LesData(:,1),LesData(:,2),'o-k')

    
else % area
        
    CodeTxt = [12,5];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(5))]);
    clique = 1;
    ComptResult = 1;
    axes(handles.axes1); hold on
    
    while clique <= 2
        [Xref,Yref,clique] = XginputX(1,handles);
        [a,b] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
        if clique <= 2
            h(ComptResult,1) = a;
            h(ComptResult,2) = b;
            plot(floor(h(ComptResult,1)),floor(h(ComptResult,2)),'.w') % point
            if ComptResult >= 2 % start
                plot([floor(h(ComptResult-1,1)),floor(h(ComptResult,1))],[floor(h(ComptResult-1,2)),floor(h(ComptResult,2))],'-k')
            end
            ComptResult = ComptResult + 1;
        end
    end
    
    % Trois points minimum...
    if length(h(:,1)) < 3
        CodeTxt = [12,6];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(6))]);
        return
    end
    
    % new V1.4.1
    plot([floor(h(1,1)),floor(h(end,1))],[floor(h(1,2)),floor(h(end,2))],'-k')
    
    [LinS,ColS] = size(Data);
    MasqueSel = Xpoly2maskX(h(:,1),h(:,2),LinS,ColS);    % updated 21.03.13
    
    Selected = Data .* MasqueSel;
    
    % Display a test of the selection:
    %figure, imagesc(MasqueSel), axis image, colorbar
    
    LesData(1,1) = 1;    
    LesData(1,2) = median(Selected(find(Selected > 0)));
    
    set(handles.SamplingDisplay,'String',num2str(LesData(1,2)));
    
end


ButtonName = questdlg('Would you like to save the results? (ASCII file)', 'Sampling', 'Yes');

switch ButtonName
    case 'Yes'

        % Save
        CodeTxt = [12,7];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(7))]);

        [Success,Message,MessageID] = mkdir('Exported-Sampling');

        cd Exported-Sampling
        [Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export results as');
        cd ..

        if ~Directory
            CodeTxt = [12,8];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            a = gca;
            axes(handles.axes1)
            zoom on
            axes(a)

            %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(8))]);
            return
        end

        fid = fopen(strcat(pathname,Directory),'w');
        fprintf(fid,'%s\n','Sampling from XMapTools');
        fprintf(fid,'%s\n',date);
        if Type == 1
            fprintf(fid,'%s\n\n','Method: Point');
        elseif Type == 2
            fprintf(fid,'%s\n\n','Method: Line');
        else
            fprintf(fid,'%s\n\n','Method: Area');
        end

        for i = 1:length(LesData(:,1))
            fprintf(fid,'%s\n',[char(num2str(LesData(i,1))),' ',char(num2str(LesData(i,2)))]);
        end

        fprintf(fid,'\n');
        fclose(fid);

        CodeTxt = [12,9];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        
end

%a = gca;
%axes(handles.axes1)
%zoom on
%axes(a)


%set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(9))]);
return
    

% #########################################################################
%     SAMPLING RECTANGLE (V2.1.4)
function BUsampling4_Callback(hObject, eventdata, handles)
%

% Define plot and extract the rectangle
[FinalData,Coords] = SelectRectangleIntegration(hObject, eventdata, handles);

% figure, hold on
% imagesc(FinalData), axis image, colorbar,
% title(['VER_XMapTools_750 - ',datestr(clock)])
% XMapColorbar(FinalData,handles,2); 

TheMean = zeros(1,size(FinalData,1));
TheMedian = zeros(1,size(FinalData,1));
TheStd = zeros(1,size(FinalData,1));
for i=1:size(FinalData,1)
    TheMean(i) = mean(FinalData(i,find(FinalData(i,:)>1e-19)));
    TheMedian(i) = median(FinalData(i,find(FinalData(i,:)>1e-19)));
    TheStd(i) = std(FinalData(i,find(FinalData(i,:)>1e-19)));
end

Nb = zeros(1,size(FinalData,1));
for i=1:size(FinalData,1)
    Nb(i) = length(find(FinalData(i,:)>1e-19));
end
FractPer = Nb/size(FinalData,2)*100;

MenuChoice = menu('What would you like to display?','[1] Mean + All','[2] Mean only','[3] Median + All','[4] Median only','[5] Mean + Median + All','[6] Mean + Median','[7] All only');

Compt = 0;
TheLeg = '';

figure, hold on
switch MenuChoice
    case {1,3,5,7} % we plot all
        for i=1:size(FinalData,2)
            plot(FinalData(:,i), 'color', [0.5 0.5 0.5])
        end
        Compt = Compt+1;
        TheLeg = [TheLeg,' All (gray) |'];
        
end

switch MenuChoice
    case {1,2,5,6} % mean
        plot(TheMean,'-r','linewidth',2);
        %plot(TheMean+TheStd,'-r','linewidth',1);
        %plot(TheMean-TheStd,'-r','linewidth',1);
        Compt = Compt+1;
        TheLeg = [TheLeg,' Mean (red) |'];
        
end

switch MenuChoice
    case {3,4,5,6}
        plot(TheMedian,'-b','linewidth',2);
        Compt = Compt+1;
        TheLeg = [TheLeg,' Median (blue) |'];
end


xlabel('Length');
ylabel('Value');
title([' XMapTools - ',datestr(clock),' ',TheLeg(1:end-1)])
        

ButtonName = questdlg('Would you like to plot the fraction of pixels used?', 'Sampling', 'Yes');

switch ButtonName
    case 'Yes'

        figure, hold on
        plot(FractPer,'--k','linewidth',2);
        
        ylabel('% of pixels used') % label right y-axis
        xlabel('Length') % label x-axis
        
        title(['XMapTools - ',datestr(clock)])
end


ButtonName = questdlg('Would you like to save the results? (ASCII file)', 'Sampling', 'Yes');

switch ButtonName
    case 'Yes'

        CodeTxt = [12,7];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(7))]);

        [Success,Message,MessageID] = mkdir('Exported-Sampling');

        cd Exported-Sampling
        [Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export results as');
        cd ..

        if ~Directory
            CodeTxt = [12,8];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            a = gca;
            axes(handles.axes1)
            zoom on
            axes(a)

            %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(8))]);
            return
        end

        fid = fopen(strcat(pathname,Directory),'w');
        fprintf(fid,'%s\n','Sampling from XMapTools');
        fprintf(fid,'%s\n',date);
        fprintf(fid,'%s\n','Method: Integrated Area');
        fprintf(fid,'%s\n\n','Columns: Mean | Median | Std | %Pixels');

        for i = 1:length(TheMean(:))
            fprintf(fid,'%12.8f\t%12.8f\t%12.8f\t%12.8f\n',[TheMean(i),TheMedian(i),TheStd(i),FractPer(i)]);
        end
        %12.8
        %fprintf(fid,'\n\n');
        %fprintf(fid,'%s\n\n','Raw Data');
        %fwrite(fid,FinalData,'int');
        
        fprintf(fid,'\n');
        fclose(fid);

        CodeTxt = [12,9];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
end


%figure,
%plot(Nb,'-r','linewidth',2)

return


% #########################################################################
%     SELECT RECTANGLE TO INTEGRATE (V2.1.1)
function [FinalData,Coords] = SelectRectangleIntegration(hObject, eventdata, handles)
%

% Recuperer les data
axes(handles.axes1)
axis image
lesInd = get(handles.axes1,'child');

% On extrait l'image...
for i=1:length(lesInd)
    leType = get(lesInd(i),'Type');
    if length(leType) == 5
        if leType == 'image';
            Data = get(lesInd(i),'CData');
        end
    end   
end

if length(Data(1,:)) > 700
    Decal(1) = 20;
elseif length(Data(1,:)) > 400
    Decal(1) = 10;
else
    Decal(1) = 5;
end

if length(Data(:,1)) > 700
    Decal(2) = 20;
elseif length(Data(:,1)) > 400
    Decal(2) = 10;
else
    Decal(2) = 5;
end

for i=1:2
    if i ==1
        CodeTxt = [12,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(3))]);
    else
        CodeTxt = [12,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        %set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(4))]);
    end
    [Xref,Yref,Clique] = XginputX(1,handles);
    [X(i),Y(i)] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
    
    if Clique == 3
        CodeTxt = [12,6];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        return
    end
    
    X(i) = round(X(i));
    Y(i) = round(Y(i));
    
    % A horizontal line crashes the code so the line can't be horizontal !!!
    if i==2
        if X(2) == X(1)
            X(2) = X(2)+1;
        end
        if Y(2) == Y(1)
            Y(2) = Y(2)+1;
        end
    end
    
    axes(handles.axes1)
    leTxt = text(X(i)-Decal(1),Y(i)-Decal(2),num2str(i));
    set(leTxt,'backgroundcolor',[1,1,1],'Color',[0,0,0],'FontName','Times New Roman','FontSize',10)
    hold on, plot(X(i),Y(i),'o','MarkerEdgeColor','r','MarkerFaceColor','w')
end


X1 = X(1);
X2 = X(2);
Y1 = Y(1);
Y2 = Y(2);

% Coordinate of the line P1-P2
[lesXP1P2,lesYP1P2] = LineCoordinate(round([X1,Y1]),round([X2,Y2]),size(Data));
Coords = [lesXP1P2,lesYP1P2];

% Calculate details regarding the area
a1 = (Y2-Y1)/(X2-X1);
b1 = Y2 - a1*X2;

% line 2 / point 1
a2 = -1/a1;
b2 = Y1 - a2*X1;

% line 3 / point 2
a3 = a2;
b3 = Y2 - a2*X2;


% Plot the Map and the line again !!!
plot(X,Y,'-m','linewidth',2);
plot(X,Y,'-k','linewidth',1);

x=1:size(Data,2);
yi2 = a2*x+b2;
yi3 = a3*x+b3;

[MaxY,MaxX] = size(Data);
LesQuels2 = find(x(:)>=1 & x(:)<=MaxX & yi2(:)>=1 & yi2(:)<=MaxY);
LesQuels3 = find(x(:)>=1 & x(:)<=MaxX & yi3(:)>=1 & yi3(:)<=MaxY);

plot(x(LesQuels2),yi2(LesQuels2),'-m');
plot(x(LesQuels3),yi3(LesQuels3),'-m');


CodeTxt = [12,10];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
 
% Select the tird point
[Xref,Yref,Clique] = XginputX(1,handles);
[X3,Y3] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
X3 = round(X3);
Y3 = round(Y3);


if Clique == 3
    CodeTxt = [12,6];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end


%plot(X3,Y3,'o','MarkerEdgeColor','r','MarkerFaceColor','w')


% Line 4 / with point3
a4 = a1;
b4 = Y3 - a4*X3;

%plot(x,a4*x+b4,'-m');

% Point 4 (intersection of L4 and L2)
X4 = (b4-b2)/(a2-a4);
Y4 = a2*X4 + b2;

%plot(X4,Y4,'o','MarkerEdgeColor','r','MarkerFaceColor','w')

% Point 5 (intersection of L4 and L3)
X5 = (b4-b3)/(a3-a4);
Y5 = a3*X5 + b3;

%plot(X5,Y5,'o','MarkerEdgeColor','r','MarkerFaceColor','w')


% Point 6
X6 = X1 - (X4-X1);
Y6 = Y1 - (Y4-Y1);

%plot(X6,Y6,'o','MarkerEdgeColor','r','MarkerFaceColor','w')

% Point 7
X7 = X2 - (X5-X2);
Y7 = Y2 - (Y5-Y2);

%plot(X7,Y7,'o','MarkerEdgeColor','r','MarkerFaceColor','w')

% Line 5
a5 = a1;
b5 = Y7 - a5*X7;

%plot(x,a5*x+b5,'-m');

yi4 = a4*x+b4;
yi5 = a5*x+b5;

LesQuels4 = find(x(:)>=1 & x(:)<=MaxX & yi4(:)>=1 & yi4(:)<=MaxY);
LesQuels5 = find(x(:)>=1 & x(:)<=MaxX & yi5(:)>=1 & yi5(:)<=MaxY);

% Figure Update                                                 (new 2.1.3)
plot(x(LesQuels4),yi4(LesQuels4),'-m');
plot(x(LesQuels5),yi5(LesQuels5),'-m');

%plot([X4,X5],[Y4,Y5],'-m');
%plot([X6,X7],[Y6,Y7],'-m');


[lesXOri,lesYOri] = LineCoordinate(round([X6,Y6]),round([X4,Y4]),size(Data));
[lesXref,lesYref] = LineCoordinate(round([X6,Y6]),round([X7,Y7]),size(Data));

DataPr = zeros(length(lesXref),length(lesXOri));  % lines = profils % col = Exp

%figure, 
%hold on
%h = gca;

for i=1:length(lesXOri) 
    
    DeltaX = lesXOri(1)-lesXOri(i);
    DeltaY = lesYOri(1)-lesYOri(i);
    
    lesX = lesXref - DeltaX;
    lesY = lesYref - DeltaY;
    
    lesX = round(lesX);
    lesY = round(lesY);
    
    for j=1:length(lesY)
        
        if lesX(j) >= 1 && lesY(j) >= 1 && lesY(j) <= size(Data,1) && lesX(j) <= size(Data,2)
            DataPr(j,i) = Data(lesY(j),lesX(j));
        else
            DataPr(j,i) = NaN;
        end
    end
    
    NbOK = length(find(lesX>0 & lesY>0));

    %axes(h)

    %plot(DataPr(:,i),'-b')
    
    %axes(handles.axes1)
    %plot(lesXref-DeltaX,lesYref-DeltaY,'-k');
    %pause(0.5)
    
    
end

%axes(h)

FinalData = DataPr;
%keyboard



return


% #########################################################################
%     GET COORDINATES OF LINE (V2.1.1)
function [lesX,lesY] = LineCoordinate(A,B,MapSize)
%

X = [A(1),B(1)];
Y = [A(2),B(2)];

LX = max(X) - min(X);
LY = max(Y) - min(Y);

LZ = round(sqrt(LX^2 + LY^2));

if X(2) > X(1)
    LesX = X(1):(X(2)-X(1))/(LZ-1):X(2);
elseif X(2) < X(1)
    LesX = X(1):-(X(1)-X(2))/(LZ-1):X(2);
else
    LesX = ones(LZ,1) * X(1);
end

if Y(2) > Y(1)
    LesY = Y(1):(Y(2)-Y(1))/(LZ-1):Y(2);
elseif Y(2) < Y(1)
    LesY = Y(1):-(Y(1)-Y(2))/(LZ-1):Y(2);
else
    LesY = ones(LZ,1) * Y(1);
end


XCoo = 1:1:MapSize(2);
YCoo = 1:1:MapSize(1);

for i = 1 : length(LesX)
    [V(i,1), IdxAll(i,1)] = min(abs(XCoo-LesX(i))); % Index X
    [V(i,2), IdxAll(i,2)] = min(abs(YCoo-LesY(i))); % Index Y
    

    if V(i,1) > 1 && IdxAll(i,1) < 2
        IdxAll(i,1) = 1-abs(V(i,1));
    end
    
    if V(i,2) > 1 && IdxAll(i,2) < 2
        IdxAll(i,2) = 1-abs(V(i,2));
    end
    

    if V(i,2) > 1 && IdxAll(i,2) > 2      % Y
        IdxAll(i,2) = MapSize(1)+abs(V(i,2));
    end
    
    if V(i,1) > 1 && IdxAll(i,1) > 2
        IdxAll(i,1) = MapSize(2)+abs(V(i,1));
    end
    
end

lesX = IdxAll(:,1);
lesY = IdxAll(:,2);
return


% #########################################################################
%     COLORMAP CHOICE (NEW V2.1.1)
function PopUpColormap_Callback(hObject, eventdata, handles)
% 
% We only call the new update general function
XMapColorbar([],handles,1);
return


% #########################################################################
%     SIZE OF THE AXES1 WINDOW (NEW V2.1.1)
function ButtonWindowSize_Callback(hObject, eventdata, handles)
if handles.PositionAxeWindowValue == 1
    handles.PositionAxeWindowValue = 2;
elseif handles.PositionAxeWindowValue == 2
    handles.PositionAxeWindowValue = 3;
else
    handles.PositionAxeWindowValue = 1;
end
guidata(hObject, handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     NEW HISTOGRAM MODE (NEW V2.1.1)
function ButtonFigureMode_Callback(hObject, eventdata, handles)
%
if handles.HistogramMode == 0   % we plot the histogram and save the map
    
    % Recuperer les data
    axes(handles.axes1)

    lesInd = get(handles.axes1,'child');

    % On extrait l'image...
    for i=1:length(lesInd)
        leType = get(lesInd(i),'Type');
        if length(leType) == 5
            if leType == 'image';
                Data = get(lesInd(i),'CData');
            end
        end   
    end
    
    TheMin = str2num(get(handles.ColorMin,'String'));
    TheMax = str2num(get(handles.ColorMax,'String'));
    
    TheDataSet = Data(find(Data(:) > TheMin & Data(:) < TheMax));
    
    hold off, cla(handles.axes2)
    
    axes(handles.axes2)
    [nelements,centers] = hist(TheDataSet,30);
    hist(Data(find(Data(:) > TheMin & Data(:) < TheMax)),30);
    
    
    h = findobj(gca,'Type','patch');  
    set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k');
    
    % Probability density function

    R = (max(TheDataSet)-min(TheDataSet))/150;
    xi=min(TheDataSet):R:max(TheDataSet);
    
    NbSimul = 50;
    TheNb = length(TheDataSet);
    TheOriginalDataSet = TheDataSet;
    TheFinalDataSet = zeros(NbSimul*length(TheOriginalDataSet),1);
    
    First = 1;
    End = First+TheNb-1;
    
    WaitBarPerso(0, hObject, eventdata, handles);

    for i=1:NbSimul
        TheFinalDataSet(First:End) = TheOriginalDataSet+randn*(TheOriginalDataSet.*(1./sqrt(TheOriginalDataSet)));
        First = End;
        End = First+TheNb-1;
    end
    
    WaitBarPerso(0.2, hObject, eventdata, handles);
    
    TheFinalDataSet = TheFinalDataSet(find(TheFinalDataSet(:) > TheMin & TheFinalDataSet(:) < TheMax));
    
    WaitBarPerso(0.5, hObject, eventdata, handles);
    
    N = hist(TheFinalDataSet,xi);
    
    WaitBarPerso(0.9, hObject, eventdata, handles);
    
    axes(handles.axes3)
    plot(xi,N,'-','linewidth',3);
    set(handles.axes3,'XTickLabel','', 'ytick',[]);
    set(handles.axes3,'Xlim',get(handles.axes2,'Xlim'));    
    
    WaitBarPerso(1, hObject, eventdata, handles);
    
    
    handles.HistogramMode = 1;
    
    
    
    
    
else % we retablish the map 
        
    handles.HistogramMode = 0;
    
end


guidata(hObject, handles);
OnEstOu(hObject, eventdata, handles);
GraphStyle(hObject, eventdata, handles);
return




% -------------------------------------------------------------------------
% 2.2) VER_XMapTools_750 SETTINGS OPTIONS
% -------------------------------------------------------------------------

% #########################################################################
%    BUTTON DISPLAY SETTINGS WINDOW (NEW 2.1.1)
function ButtonSettings_Callback(hObject, eventdata, handles)
%
% here some settings...

WhatDoWeDo = handles.OptionPanelDisp;

switch WhatDoWeDo
    case 0
        set(handles.UiPanelOptions,'visible','on');
        handles.OptionPanelDisp = 1;
        axes(handles.axes1), zoom off        
    case 1
        set(handles.UiPanelOptions,'visible','off');
        handles.OptionPanelDisp = 0;
        axes(handles.axes1), zoom on
end

guidata(hObject, handles);
return


% #########################################################################
%    BUTTON SAVE DEFAULT SETTINGS (NEW 2.1.1)
function ButtonSaveSettings_Callback(hObject, eventdata, handles)
%
Default_XMaptools = zeros(20,1);

Default_XMapTools(1) = get(handles.DisplayComments,'Value');
Default_XMapTools(2) = get(handles.ActivateDiary,'Value');
Default_XMapTools(3) = get(handles.DisplayActions,'Value');
Default_XMapTools(4) = get(handles.DisplayCoordinates,'Value');

Default_XMapTools(5) = get(handles.PopUpColormap,'Value');

save([handles.LocBase,'/Default_XMapTools.mat'],'Default_XMapTools');

CodeTxt = [3,4];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

ButtonSettings_Callback(hObject, eventdata, handles)
return


% #########################################################################
%    BUTTON DISPLAY ADMIN WINDOW (NEW 2.1.3)
function ADMINbutton1_Callback(hObject, eventdata, handles)
%

WhatDoWeDo = handles.AdminPanelDisp;

switch WhatDoWeDo
    case 0
        set(handles.UiPanelAdmin,'visible','on');
        handles.AdminPanelDisp = 1;
        axes(handles.axes1), zoom off        
    case 1
        set(handles.UiPanelAdmin,'visible','off');
        handles.AdminPanelDisp = 0;
        axes(handles.axes1), zoom on
end

guidata(hObject, handles);

return


% #########################################################################
%     BUTTON DISPLAY COMMENT V1.4.1
function DisplayComments_Callback(hObject, eventdata, handles)
OnAffiche = get(handles.DisplayComments,'Value');

if OnAffiche
    set(handles.TxtControl,'Visible','on')
else
    set(handles.TxtControl,'Visible','off ')
end

guidata(hObject,handles);


% #########################################################################
%     SETTINGS - DISPLAY WAITING BAR ???
function DispWait_Callback(hObject, eventdata, handles)
return


% #########################################################################
%     SETTINGS - ACTIVATE DIARY (NEW V2.1.1)
function ActivateDiary_Callback(hObject, eventdata, handles)
%
warn = warndlg({'In order to apply this setting, you must', ...
                '(1) Save the default settings', ...
                '(2) Save your project', ...
                '(3) Restart XMapTools ...'},'XMapTools warning');

return


% #########################################################################
%     SETTINGS - DISPLAY ACTIONS (NEW V2.1.1)
function DisplayActions_Callback(hObject, eventdata, handles)
return


% #########################################################################
%     SETTINGS - DISPLAY COORDINATES (NEW V2.1.1)
function DisplayCoordinates_Callback(hObject, eventdata, handles)
return




% -------------------------------------------------------------------------
% 3) PROJECT FUNCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%     OPEN BACKUP V2.1.3
function Button2_Callback(hObject, eventdata, handles)

CodeTxt = [1,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',handles.TxtDatabase(1).txt(1));

[filename, pathname] = uigetfile('*.mat', 'Select a project');

CodeTxt = [1,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

if filename
    ProjectPath = strcat(pathname,filename);
else
    ProjectPath = '';
end

XMapTools_LoadProject(hObject, eventdata, handles, ProjectPath, filename);
return


% #########################################################################
%     FUNCTION LOAD PROJECT V2.1.3
function XMapTools_LoadProject(hObject, eventdata, handles, ProjectPath, filename)
set(gcf, 'WindowButtonMotionFcn', '');

WaitBarPerso(0, hObject, eventdata, handles);

% set(handles.TxtControl,'String',handles.TxtDatabase(1).txt(2));
WaitBarPerso(0.35, hObject, eventdata, handles);
drawnow
    
if filename
    load(ProjectPath);
else 
    CodeTxt = [1,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',handles.TxtDatabase(1).txt(4));
    disp('loading a project ... (No file selected) ... CANCELATION'); disp(' ')
    WaitBarPerso(1, hObject, eventdata, handles);
    return
end

WaitBarPerso(0.90, hObject, eventdata, handles);

handles.currentdisplay = 1; % Input change
AffOPT(1, hObject, eventdata, handles);

set(handles.QUppmenu2,'Value',1); % Input Change
set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0);

set(handles.PPMenu1,'string',ListMap);
set(handles.PPMenu1,'Value',1)


cla(handles.axes1,'reset');
axes(handles.axes1), imagesc(XimrotateX(Data.map(1).values,handles.rotateFig)), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]);
XMapColorbar(Data.map(1).values,handles,1)

zoom on                                                         % New 1.6.2

set(handles.ColorMin,'String',min(min(Data.map(1).values)));
set(handles.ColorMax,'String',max(max(Data.map(1).values)));
set(handles.FilterMin,'String',min(min(Data.map(1).values)));
set(handles.FilterMax,'String',max(max(Data.map(1).values)));


handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(Data.map(1).values(find(Data.map(1).values(:) ~= 0)),30)

% -----------------------------
% Data (Update REFs):                                             New 2.1.5
for i=1:length(Data.map(:))
    Data.map(i).ref = find(ismember(handles.NameMaps.elements,char(Data.map(i).name)));
end

% -----------------------------
% List of mask files:
Compt = 1; Ok=0;
for i=1:length(MaskFile)
    if MaskFile(i).type >= 1
        ListMaskFile(Compt) = MaskFile(i).Name;
        Ok=1;
        Compt = Compt+1;
    end
end
if Ok
    set(handles.PPMenu3,'String', ListMaskFile);
    set(handles.PPMenu3,'Value',1);
    
    NameMinerals = MaskFile(1).NameMinerals;
    set(handles.PPMenu2,'String',NameMinerals)
end

% -----------------------------
% Corrections:
if exist('Corrections','var')
    % New backup 2.1.1 and latest releases
    if Corrections(1).value ==1
        set(handles.CorrButtonBRC,'Enable','on');
    end
    
    % Here define the strategy for the second correction
    
else
    Corrections(1).name = 'BRC';
    Corrections(1).value = 0;
    %
    Corrections(2).name = 'TRC';
    Corrections(2).value = 0;
end

% -----------------------------
% Profils: 
if size(Profils,1) == 1
    set(handles.PRAffichage1,'String',Profils.display);
end

% -----------------------------
% Quanti
if length(Quanti) > 1
    for i=1:length(Quanti)
        NameMinQuanti{i} = char(Quanti(i).mineral);
    end
    set(handles.QUppmenu2,'String',NameMinQuanti); 
    set(handles.QUppmenu2,'Value',1);
end

%set(handles.QUppmenu1,'String',Quanti(Onlit).listname);

% -----------------------------
% Results
if length(Results)>=1
    ListTher(1) = {'none'};
    for i=1:length(Results)
        ListTher(i+1) = Results(i).method;
    end
    
    Onest = length(ListTher);
    
    set(handles.REppmenu1,'String',ListTher);
    set(handles.REppmenu1,'Value',1);
    
end
 
% -----------------------------
% loading: 
handles.project = filename;
handles.save = 1;
handles.data = Data;
handles.ListMap = ListMap;
handles.corrections = Corrections;
handles.MaskFile = MaskFile;
handles.profils = Profils;
handles.quanti = Quanti;
handles.results = Results;


CodeTxt = [1,3];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(filename),' ',char(handles.TxtDatabase(1).txt(3))])
WaitBarPerso(1, hObject, eventdata, handles);

disp(['loading a project ... (',filename,') ... Ok']); disp(' ')
disp([' ########## The current project is : ',filename,' ##########'])
disp(' ')
set(handles.TextProjet,'String',filename);


% NEW VARIABLES TEST

% 1.6.2 PointSelected
if length(Profils) > 0
    if ~myIsField(handles,'pointselected')
        handles.profils.pointselected = ones(size(handles.profils.coord,1),1);
    end
end

% Display coordinates new 1.5.4 (11/2012)
set(gcf, 'WindowButtonMotionFcn', @mouseMove);    % in the end we wait for handles saved first...

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
set(handles.axes1,'xtick',[], 'ytick',[]);
GraphStyle(hObject, eventdata, handles)
return


% #########################################################################
%     SAVE V2.1.1
function Button3_Callback(hObject, eventdata, handles)
set(gcf, 'WindowButtonMotionFcn', '');

Onsave = handles.save;

CodeTxt = [2,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[handles.TxtDatabase(2).txt(1)])
WaitBarPerso(0, hObject, eventdata, handles);
drawnow
WaitBarPerso(0.1, hObject, eventdata, handles);

% On recupere les variables a sauvegarder :
Data = handles.data;
MaskFile = handles.MaskFile;
ListMap = handles.ListMap;
Corrections = handles.corrections;
Profils = handles.profils;
Quanti = handles.quanti;
Results = handles.results;

if Onsave == 1
    WaitBarPerso(0.25, hObject, eventdata, handles);
    % Sauvegarde n + 1;
    Directory = handles.project;
    save(Directory,'Directory','Data','ListMap','Corrections','MaskFile','Profils','Quanti','Results');
    disp(['Saving current project ... (',Directory,') ... Ok']), disp(' ')
else
    % On propose une sauvegarde
    CodeTxt = [2,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[handles.TxtDatabase(2).txt(2)])
    drawnow
    
    [Directory, pathname] = uiputfile({'*.mat', 'MATLAB File (*.mat)'}, 'Save the project as');
    if Directory
        WaitBarPerso(0.25, hObject, eventdata, handles);
        save(strcat(pathname,Directory),'Directory','Data','ListMap','Corrections','MaskFile','Profils','Quanti','Results');
        disp(['Saving a new project ... (',Directory,') ... Ok']), disp(' ')
    	([' * * * * * * * * The current project is : ',Directory,' * * * * * * * *']), disp(' ')
        set(handles.TextProjet,'String',Directory);
    else
        CodeTxt = [2,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        % set(handles.TxtControl,'String',[handles.TxtDatabase(2).txt(4)])
        return
    end
end

WaitBarPerso(0.95, hObject, eventdata, handles);
handles.project = Directory;
handles.save = 1;

h = clock;
WaitBarPerso(1, hObject, eventdata, handles);

CodeTxt = [2,3];
set(handles.TxtControl,'String',[char(Directory),' ',char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(h(4)),'h',num2str(h(5)),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(Directory),' ',char(handles.TxtDatabase(2).txt(3)),' (',num2str(h(4)),'h',num2str(h(5)),')']);

set(gcf, 'WindowButtonMotionFcn', @mouseMove);
guidata(hObject,handles);
return


% #########################################################################
%     SAVE AS ... V1.6.1
function Button5_Callback(hObject, eventdata, handles)
set(gcf, 'WindowButtonMotionFcn', '');

Onsave = handles.save;

Data = handles.data;
MaskFile = handles.MaskFile;
ListMap = handles.ListMap;
Corrections = handles.corrections;
Profils = handles.profils;
Quanti = handles.quanti;
Results = handles.results;

CodeTxt = [2,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[handles.TxtDatabase(2).txt(2)])
drawnow


[Directory, pathname] = uiputfile({'*.mat', 'MATLAB File (*.mat)'}, 'Save the project as');
if Directory
    WaitBarPerso(0.3, hObject, eventdata, handles);
    save(strcat(pathname,Directory),'Directory','Data','ListMap','Corrections','MaskFile','Profils','Quanti','Results');
    disp(['Saving a new project ... (',Directory,') ... Ok']), disp(' ')
    disp([' * * * * * * * * The current project is : ',Directory,' * * * * * * * *']), disp(' ')
    set(handles.TextProjet,'String',Directory); % updated 1.6.1 (P. Lanari)
else
    CodeTxt = [2,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[handles.TxtDatabase(2).txt(4)])
    return
end

handles.project = Directory;
handles.save = 1;
WaitBarPerso(0.9, hObject, eventdata, handles);

h = clock;
WaitBarPerso(1, hObject, eventdata, handles);

CodeTxt = [2,3];
set(handles.TxtControl,'String',[char(Directory),' ',char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(h(4)),'h',num2str(h(5)),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(Directory),' ',char(handles.TxtDatabase(2).txt(3)),' (',num2str(h(4)),'h',num2str(h(5)),')']);

set(gcf, 'WindowButtonMotionFcn', @mouseMove);
guidata(hObject,handles);
return


% #########################################################################
%     NEW V1.5.1
function Button1_Callback(hObject, eventdata, handles)

close all % end of program.
XMapTools % new XmapTool

return


% #########################################################################
%     EXIT V1.5.1
function Button4_Callback(hObject, eventdata, handles)
%

close all
return


% #########################################################################
%     EXIT                                                          V 2.1.3
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%

if handles.update == 1
    delete(gcf);
    return
end
  
OnPropose = 1;

data = handles.data;
if length(data.map) == 1 && data.map(1).type == 0% type=0 ON EST ICI
    OnPropose = 0;
end

    
if OnPropose    
ButtonName = questdlg('Save the project ?', ...
                      'XMapTools', ...
                      'Don''t Save', 'Cancel', 'Save','Don''t Save');

drawnow; pause(0.05);  % this innocent line prevents the Matlab hang
                  
switch ButtonName
    case 'Save'
        % execute la fonction de sauvegarde
        Button3_Callback(hObject, eventdata, handles);        
    case 'Cancel'
        % Alors on annule la fermeture
        return
    end 
% Pas de case No bien sur... 
end

% New 1.6.2 delete the favorite paths...
fid = fopen('Config.txt');
LocBase = char(fgetl(fid)); % main directory of xmap tools
fclose(fid);
% Addpath:
FunctionPath = strcat(LocBase,'/Functions');
rmpath(FunctionPath);
ModulesPath = strcat(LocBase,'/Modules');
rmpath(ModulesPath);
ModulesPath = strcat(LocBase,'/Dev');
rmpath(ModulesPath);

if exist(strcat(LocBase(1:end-7),'/UserFiles')) == 7        % test if the directory exists
    FunctionPath = strcat(LocBase(1:end-7),'/UserFiles');
    rmpath(FunctionPath);
end


Date = clock;
disp('-----------------------------')
disp([num2str(Date(3)),'/',num2str(Date(2)),'/',num2str(Date(1)),' ',num2str(Date(4)),'h',num2str(Date(5)),'''',num2str(round(Date(6))),''''''])
disp(' ');
disp('-- END OF EXECUTION (Exit) --')
disp(' ')

if handles.diary
    diary off
end

handles.update = 1;
guidata(hObject,handles);

% This works with MATLAB 2014b
try close(gcf); catch, end
delete(gcf);
close all force
return



% -------------------------------------------------------------------------
% 4) XRAY FUNCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%     ADD A NEW MAP. (V1.6.2) 
function MButton1_Callback(hObject, eventdata, handles)
NameMaps = handles.NameMaps.filename;
AffNameMaps = handles.NameMaps.elements;
References = handles.NameMaps.ref;

Data = handles.data;

% Changes for associated menus 
handles.currentdisplay = 1; % Input change
set(handles.QUppmenu2,'Value',1); % Input Change
set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0);

[FileName,PathName,FilterIndex] = uigetfile({'*.txt;*.asc;*.dat;*.csv;','Map Files (*.txt, *.asc, *.dat, *.csv)';'*.*',  'All Files (*.*)'},'Pick map file(s)','MultiSelect', 'on');

if ~FilterIndex
    CodeTxt = [5,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(2))]);
    drawnow
    return
end
if length(char(FileName(1))) > 1
    NMaps = length(FileName);
else
    NMaps = 1;
end
   
set(gcf, 'WindowButtonMotionFcn', '');

for i=1:NMaps % version 1.4.1
	% pre-selection :
    if NMaps == 1
        Name = {FileName(1:end-4)}; % end-4 pour l'extension
        NameExt = char(FileName);
    else
        NameExt = char(FileName(i));
        Name = NameExt(1:end-4);
    end
    % search:
    [Position] = ismember(NameMaps,Name);
    if sum(Position) == 0
        Position2 = ismember(AffNameMaps,Name);
    end
    
  	if sum(Position) > 0
        CodeTxt = [5,1];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

     	% set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(1)),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']);
     	drawnow
        [Selection,OK] = listdlg('promptstring','Select a name','selectionmode','single','liststring',AffNameMaps,'initialvalue',find(Position,1));
    else
        if sum(Position2) > 0
            
            CodeTxt = [5,1];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        	% set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(1)),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']);
            drawnow
            [Selection,OK] = listdlg('promptstring','Select a name','selectionmode','single','liststring',AffNameMaps,'initialvalue',find(Position2,1));
        else
            
            CodeTxt = [5,1];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(1)),' ',char(NameExt),' (',char(num2str(i)),'/',char(num2str(NMaps)),')']);
            drawnow
            [Selection,OK] = listdlg('promptstring','Select a name','selectionmode','single','liststring',AffNameMaps);
        end
    end    
    if OK == 0
        CodeTxt = [5,2];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);    

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(2))]);
        drawnow
        return
    end
    
    CodeTxt = [5,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);    

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(3))]);
    WaitBarPerso(0.35, hObject, eventdata, handles);
    drawnow
    %loading
    NewMap = load([PathName,NameExt]);   % updated 1.6 (P. Lanari)
    
    WaitBarPerso(0.70, hObject, eventdata, handles);
    % intensity correction (see De Andrade, 2006 phd)
    for j=1:length(NewMap(:,1))
        for k=1:length(NewMap(1,:))
            NewMapCorr(j,k) = NewMap(j,k) / (1 - (0.3e-6) * NewMap(j,k));
        end
    end
    
    NewName = AffNameMaps(Selection);
    NewRef = References(Selection);
    
    WaitBarPerso(0.99, hObject, eventdata, handles);
    
    % Plot (A voir si on laisse)
    
    DataTempNMap(i).NewMapCorr = NewMapCorr;
    DataTempNMap(i).NewMap = NewMap;
    DataTempNMap(i).NewName = NewName;
    DataTempNMap(i).NewRef = NewRef;
    
    WaitBarPerso(1, hObject, eventdata, handles);
       
end

% Dans cette nouvelle version on ne peut pas avoir d'espace type=0 (XMT v1.3), 
% donc pas besoin de gerer le remplacement, on met tout à la fin...

nMapsloaded = length(Data.map);
if nMapsloaded == 1;
    if Data.map(1).type
        OnEcritFrom = 2; % On a une carte
    else
        OnEcritFrom = 1; % on a zeros cartes
    end
else
    OnEcritFrom = nMapsloaded + 1; % on a n cartes
end

Concat='';
for i=1:NMaps
    OnEcritici = OnEcritFrom + i - 1; % et oui i)1 = 1;

    Concat =strcat(Concat,char(DataTempNMap(i).NewName),'-');
    
    Data.map(OnEcritici).type = 1; % raw data
    Data.map(OnEcritici).name = DataTempNMap(i).NewName; % Name
    Data.map(OnEcritici).values = DataTempNMap(i).NewMapCorr; % data
    Data.map(OnEcritici).ref = DataTempNMap(i).NewRef; % for element reference.
    Data.map(OnEcritici).corr = [round(mean(DataTempNMap(i).NewMap)),round(mean(DataTempNMap(i).NewMapCorr))];

end
Concat = char(Concat);
ConcatF = Concat(1:end-1);

% Update LIST for display
Compt = 1; 
for i=1:length(Data.map(:)), if Data.map(i).type == 1, ListMap(Compt) = Data.map(i).name; Compt = Compt + 1; end, end
    
set(handles.PPMenu1,'string',ListMap);
set(handles.PPMenu1,'Value',OnEcritici) % dernière map chargée

handles.data = Data; % send
handles.ListMap = ListMap;


% PLOT
guidata(hObject,handles);
PPMenu1_Callback(hObject, eventdata, handles);

% cla(handles.axes1,'reset');
% axes(handles.axes1), imagesc(XimrotateX(AAfficher,handles.rotateFig)), axis image, colorbar('vertical')
% set(handles.axes1,'xtick',[], 'ytick',[]); 
% XMapColorbar(AAfficher,handles)
% 
% zoom on                                                         % New 1.6.2
% 
% % Display coordinates new 1.5.4 (11/2012)
% set(gcf, 'WindowButtonMotionFcn', @mouseMove);
% 
% set(handles.ColorMin,'String',min(min(AAfficher)));
% set(handles.ColorMax,'String',max(max(AAfficher)));
% set(handles.FilterMin,'String',min(min(AAfficher)));
% set(handles.FilterMax,'String',max(max(AAfficher)));
% 
% 
% cla(handles.axes2);
% axes(handles.axes2), hist(NewMapCorr(find(AAfficher(:) ~= 0)),30)

if NMaps == 1
    CodeTxt = [5,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(ConcatF),')']); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);    

    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(4)),' (',char(ConcatF),')']);
else
    CodeTxt = [5,5];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(ConcatF),')']); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);    

    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(5).txt(5)),' (',char(ConcatF),')']);
end
drawnow 

% ancienne version d'affichage 
% disp(['Adding ... (Raw data: ',char(FileName),') ... ']);
% disp(['Adding ... (Element: ',char(NewName),') ']);
% disp(['Adding ... (Average Intensity: ',num2str(round(mean(NewMap(:)))),' before timeout correction)']);
% disp(['Adding ... (Average Intensity: ',num2str(round(mean(NewMapCorr(:)))),' after timeout correction)']);
% disp(['Adding ... (Raw data: ',char(FileName),') ... Ok']);
% disp(' ');
% 
% 
GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     DELETE THE SELECTED MAP (V1.6.2)
function MButton2_Callback(hObject, eventdata, handles)
ListMap = handles.ListMap;
Data = handles.data;

% Changes for associated menus 
handles.currentdisplay = 1; % Input change
set(handles.QUppmenu2,'Value',1); % Input Change
set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0);

Delete = get(handles.PPMenu1,'Value');
DelList = get(handles.PPMenu1,'String');
DelName = DelList(Delete);

if Delete == 1 % On enleve la premiere map
    for k = 1:length(ListMap) - 1
        NewData.map(k) = Data.map(k+1);
        NewListMap(k) = ListMap(k+1);
    end
end
if Delete > 1 && Delete < length(ListMap)
    NewListMap(1:Delete-1) = ListMap(1:Delete-1); 
    for k = 1:Delete
        NewData.map(k) = Data.map(k);
        NewListMap(k) = ListMap(k);
    end
    for k = Delete:length(ListMap)-1
        NewData.map(k) = Data.map(k+1);
        NewListMap(k) = ListMap(k+1);
    end
end
if Delete == length(ListMap)
    for k = 1:length(ListMap) - 1
        NewData.map(k) = Data.map(k);
        NewListMap(k) = ListMap(k);
    end
%     Old version
%     Data.map(Delete).type = 0;
%     Data.map(Delete).name = {};
% 	Data.map(Delete).values = [];
%     NewListMap = ListMap(1:Delete-1);
end


set(handles.PPMenu1,'Value',1);
set(handles.PPMenu1,'String',NewListMap);

handles.ListMap = NewListMap;
handles.data = NewData;

cla(handles.axes1,'reset');
guidata(hObject,handles);
PPMenu1_Callback(hObject, eventdata, handles)   % New 2.1.1


% axes(handles.axes1), imagesc(XimrotateX(NewData.map(1).values,handles.rotateFig)), axis image, colorbar('vertical')
% XMapColorbar(NewData.map(1).values,handles)
% 
% zoom on                                                         % New 1.6.2
% 
% cla(handles.axes2);
% axes(handles.axes2), hist(NewData.map(1).values(find(Data.map(1).values(:) ~= 0)),30)



CodeTxt = [4,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(DelName),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(4).txt(1)),' (',char(DelName),')'])

disp(['Deleting ... (Raw data: ',char(DelName),') ... Ok']); disp(' ');


guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
set(handles.axes1,'xtick',[], 'ytick',[]);
GraphStyle(hObject, eventdata, handles)
return


% #########################################################################
%     MAPS INFO BOX  (V2.1.1)
function MButton3_Callback(hObject, eventdata, handles)
    
Value = get(handles.UiPanelMapInfo,'Visible');

if length(char(Value)) < 3 % alors 'on'
    set(handles.UiPanelMapInfo,'Visible','off');
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    zoom on
else
    set(handles.UiPanelMapInfo,'Visible','on');
    set(gcf, 'WindowButtonMotionFcn', '');
    zoom off
end

MaskFile = handles.MaskFile;
MaskSelected = get(handles.PPMenu3,'Value');

% Display
Selected = get(handles.PPMenu1,'Value');
Data = handles.data;

DispName = Data.map(Selected).name;
DispRef = Data.map(Selected).ref; 
DispSize = size(Data.map(Selected).values);

% UPDATED 30/04/12 (use the average compositon of the selected mineral)
MineralSelected = get(handles.PPMenu2,'Value');

if MineralSelected < 2
    MatrixData = Data.map(Selected).values(:);
    
    DispMineral = 'not used (all pixels are displayed)';
    
    DispMean = mean(MatrixData);
    DispError = ((2/(sqrt(DispMean)))*100);                  % edited 1.6.2
    DispStd = std(MatrixData);
    DispMin = min(MatrixData);
    DispMax = max(MatrixData);
    
    DispMedian = median(MatrixData);                          % Added 2.1.1
    DispMError = ((2/(sqrt(DispMedian)))*100);
    
else
    RefMin = MineralSelected - 1;
    PourCalcul = MaskFile(MaskSelected).Mask == RefMin;
    
    MatrixData = Data.map(Selected).values(:) .* PourCalcul(:);

    DispMineral = MaskFile(MaskSelected).NameMinerals{MineralSelected};
    
    DispMean = mean(MatrixData(find(PourCalcul(:))));
    DispError = ((2/(sqrt(DispMean)))*100);
    DispStd = std(MatrixData(find(PourCalcul(:))));
    DispMin = min(MatrixData(find(PourCalcul(:))));
    DispMax = max(MatrixData(find(PourCalcul(:))));
    
    DispMedian = median(MatrixData(find(PourCalcul(:))));     % Added 2.1.1
    DispMError = ((2/(sqrt(DispMedian)))*100);
    
end

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    FilteredPixels = length(find(handles.corrections(1).mask == 0));
    NbTotal = size(handles.corrections(1).mask,1)*size(handles.corrections(1).mask,2);
    StateCorrectionBRC = ['applied (',num2str(FilteredPixels/NbTotal*100),'% of pixels filtered)'];
else
    StateCorrectionBRC = 'not applied';
end

if handles.corrections(2).value == 1
    % there is a BRC correction available
    StateCorrectionTRC = 'applied';
else
    StateCorrectionTRC = 'not applied';
end

% -> Define the shift variable
if isfield(handles.data.map(Selected),'shift')
    if sum(abs(handles.data.map(Selected).shift))>0
        StateCorrectionMPC = ['applied [',num2str(handles.data.map(Selected).shift(1)),';',num2str(handles.data.map(Selected).shift(2)),']'];
    elseif isequal(length(handles.data.map(Selected).shift),2)
        StateCorrectionMPC = 'not applied [0,0]';
    else 
        StateCorrectionMPC = 'not applied';
    end
else
    StateCorrectionMPC = 'not applied';
end


%DispFinal{1} = ['*** RAW DATA DETAILS ***'];
%DispFinal{1} = [' - - - - - - - - -'];
DispFinal{1} = ['* selected element: ',char(DispName),'  (ref = ',char(num2str(DispRef)),')'];
DispFinal{end+1} = ['* selected mineral: ',char(DispMineral)];
DispFinal{end+1} = [' - - - - - - - - -'];
DispFinal{end+1} = ['* map size: ',char(num2str(DispSize(1))),' rows & ',char(num2str(DispSize(2))),' columns'];
DispFinal{end+1} = [' - - - - - - - - -'];
DispFinal{end+1} = ['* mean intensity = ',char(num2str(DispMean)),' (error 2o = ',char(num2str(DispError)),' % [1])'];
DispFinal{end+1} = ['* median intensity = ',char(num2str(DispMedian)),' (error 2o = ',char(num2str(DispMError)),' % [1])'];
DispFinal{end+1} = ['* standard deviation = ',char(num2str(DispStd))];
DispFinal{end+1} = ['* min value = ',char(num2str(DispMin))];
DispFinal{end+1} = ['* max value = ',char(num2str(DispMax))];
DispFinal{end+1} = [' - - - - - - - - -'];
DispFinal{end+1} = ['* BRC correction: ',char(StateCorrectionBRC)];
DispFinal{end+1} = ['* TRC correction: ',char(StateCorrectionTRC)];
DispFinal{end+1} = ['* MPC correction: ',char(StateCorrectionMPC)];
DispFinal{end+1} = [' - - - - - - - - -'];
DispFinal{end+1} = ['[1] Errors - Poisson distribution (see Lanari et al. 2014)'];



% mise a jour de la taille
NbLines = length(DispFinal) * 0.022;
MaxFin = 0;
for i=1:length(DispFinal)
    MaxTemp = length(char(DispFinal(i)));
    if MaxTemp > MaxFin
        MaxFin = MaxTemp;
    end
end
NbCol = MaxFin * 0.0055;

VectMod = get(handles.InfosBox,'Position');
VectMod(3:4) = [NbCol,NbLines];
%set(handles.InfosBox,'Position',VectMod);

set(handles.InfosBox,'String',DispFinal,'visible', 'on');

guidata(hObject,handles);
return


% #########################################################################
%     CLASSIFICATION: CREATE A NEW MASK SET (V1.6.5)
function MaskButton1_Callback(hObject, eventdata, handles)
Data = handles.data;
MaskFile = handles.MaskFile;
MethodV = get(handles.PPMaskMeth,'Value');
MethodL = get(handles.PPMaskMeth,'String');
Method = MethodL(MethodV);

%Ou est ce que l'on va ajouter ce fichier mask ?
if length(MaskFile) == 1
    if MaskFile(1).type
        OnEcritMaskFile = length(MaskFile) + 1; % fixed bug v1.5
    else
        OnEcritMaskFile = 1;
    end
else
    OnEcritMaskFile = length(MaskFile) + 1; % fixed bug v1.5
end

Selected = get(handles.PPMenu1,'Value');
 
ListMap = handles.ListMap;


CodeTxt = [7,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(1))]);

AutoSelect = [1:1:length(ListMap)];
[SelectedMap,Ok] = listdlg('ListString',ListMap,'SelectionMode','multiple','Name','Select Maps','InitialValue',AutoSelect);

if length(SelectedMap) < 2   % Added 22/09/2012 P. Lanari (new 1.5.4)
    CodeTxt = [7,4]; % A CHANGER ICI IL FAUT AU MINIMUM DEUX CARTES !!!
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    return
end

if Ok == 0
    CodeTxt = [7,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(4))]);
    return
end

ConcatMapName = '';
for i=1:length(SelectedMap)
    SelectedData(i) = Data.map(SelectedMap(i));
    
    % Pour affichage, new 1.5.4 (11/2012)
    ConcatMapName = [ConcatMapName,' ',char(ListMap(SelectedMap(i)))];
    
end
NbdeMaps = length(SelectedMap);

CodeTxt = [7,2];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(2))]);

% in this version NbdeMap is > 1



% NEW 1.6.5
ChoiceMeth = get(handles.PPMaskFrom,'Value');

% CodeTxt = [7,14];
% set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
% TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
% 
% [ChoiceMeth,OK] = listdlg('ListString',{'From the Maps (click)','From a file'},'Name','Input pixels');
% 
% if ~OK
%     CodeTxt = [7,10];
%     set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
%     TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
%     return
% end

switch ChoiceMeth
    case 2
        % Update 1.6.5 - New feature - load a file

        % - - - Update 2.1.4 - Automatic opening of Classification.txt
        
        if isequal(exist('Classification.txt','file'),2)
            ButtonName = questdlg('Would you like to used Classification.txt?','Classification','Yes');  
            switch ButtonName
                case 'Yes'
                    Question = 0;
                    filename = 'Classification.txt';
                otherwise
                    Question = 1;
            end         
        else
            Question = 1;
        end
        
        if Question
            [filename, pathname] = uigetfile({'*.txt';'*.*'},'Pick a file');

            if ~filename
                CodeTxt = [7,10];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
                return
            end

            fid = fopen([pathname,filename],'r');
        else
            fid = fopen([filename],'r');
        end
        
        % - - - 
        
        NameMinerals(1) = {'none'};
        
        Compt = 0;
        while 1
            LaLign = fgetl(fid);
            
            if isequal(LaLign,-1)
                break
            end
            
            if ~isequal(LaLign,'')
                if isequal(LaLign(1),'>')
                    
                    while 1
                        LaLign = fgetl(fid);
                        
                        if isequal(LaLign,-1) || isequal(LaLign,'') 
                            break
                        end
                        
                        Compt = Compt+1;
                        LaLignPropre = strread(LaLign,'%s');

                        NameMinerals{Compt+1} = LaLignPropre{1};
                        
                        
                        X = str2num(LaLignPropre{2});
                        Y = str2num(LaLignPropre{3});
                        
                        [SelPixelX,SelPixelY] = CoordinatesFromRef(X,Y,handles);
                        
                        CenterPixels(Compt,1) = SelPixelX;  % now in display coordinates
                        CenterPixels(Compt,2) = SelPixelY;  % now in display coordinates.
                        
                        % Which is what we would like... Corrected in 2.1.1
                    end


                end
            end
        end
        
        axes(handles.axes1); hold on
        plot(CenterPixels(:,1),CenterPixels(:,2), 'mo','linewidth', 2)
        
        NbMask = length(NameMinerals)-1;
        
        
    case 1   % clicking (old version)

        axes(handles.axes1); hold on

        clique = 1; ComptMask = 1;
        while clique < 2
            [Xref,Yref,clique] = XginputX(1,handles); % we select the pixel
            [SelPixel(1),SelPixel(2)] = CoordinatesFromRef(Xref,Yref,handles);   % update 1.6.2 XimrotateX
            % -- Now we are working with the Fig coordinates (For Display)
            if clique < 2
                CenterPixels(ComptMask,:) = round(SelPixel);
                plot(CenterPixels(:,1),CenterPixels(:,2), 'mo','linewidth', 2)
                ComptMask = ComptMask+1;
            end
        end
        NbMask = ComptMask-1;
        
        % --------------------------------------
        % Minerals Name (defaut)
        NameMinerals(1) = {'none'};
        for i=1:NbMask
            TempO = strcat('Mineral',num2str(i));
            NameMinerals(i+1,:) = {TempO};
        end
        
end

CodeTxt = [7,3];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

if NbMask < 2   % update 1.6.5
    CodeTxt = [7,10];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end


Xfig = CenterPixels(:,1);
Yfig = CenterPixels(:,2);
[Xref,Yref] = CoordinatesFromFig(Xfig,Yfig,handles);   % update 1.6.2 XimrotateX
CenterPixels = [Xref,Yref];
% -- Now we are working with the Ref coordinates (For projection)

Name = inputdlg('Mask file name','define a name',1,{['Meth',num2str(MethodV),'-MaskFile',num2str(OnEcritMaskFile)]});

if length(Name) == 0
    CodeTxt = [7,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles); 
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(4))]);
    return
end

% Chemic variable creation:
Compt = 1;
for i=1:length(SelectedData(:))
	if Data.map(i).type == 1
    	% it's a raw data map
        Chemic(:,Compt) = SelectedData(i).values(:);
        SizeMap = size(SelectedData(i).values);
        Compt = Compt+1;
    end
end
nPixH = SizeMap(1,2); nPixV = SizeMap(1,1);
NumPixCenter = (CenterPixels(:,1)-1).*nPixV + CenterPixels(:,2);

% TEST Display
%figure, imagesc(SelectedData(1).values), axis image, hold on, plot(CenterPixels(:,1),CenterPixels(:,2),'om');
 
CodeTxt = [7,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

% set(handles.TxtControl,'String',handles.TxtDatabase(7).txt(9));
WaitBarPerso(0, hObject, eventdata, handles);
WaitBarPerso(0.35, hObject, eventdata, handles);
drawnow

% New 1.4.1
DureeCalc = ((SizeMap(1,1) * SizeMap(1,2) * NbMask) * 10^-6 + 0.2126 ) * 3; % secondes  *3 for lag-time...
% estimated using 6 maps between 22880 and 717120 pixels on a MacBook 13';

CodeTxt = [7,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (~ ',char(num2str(round(DureeCalc))),' s)']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(9)),' (~ ',char(num2str(round(DureeCalc))),' s)']);
drawnow

% tic

set(gcf, 'WindowButtonMotionFcn', '');

% METHOD 1 - Classic Computation
if MethodV == 1
    Groups = XkmeansX(Chemic, NbMask, 'start', Chemic(NumPixCenter,:)); 
    Groups = reshape(Groups, nPixV, nPixH);    
end

% METHOD 2 - Normalized intensities
if MethodV == 2
    moyChem = mean(Chemic);
    stdChem = std(Chemic);
    ChemicNorm = (Chemic - ones(nPixV*nPixH,1)*moyChem) ./ (ones(nPixH*nPixV,1)*stdChem);
    
    Groups = XkmeansX(ChemicNorm, NbMask, 'start', ChemicNorm(NumPixCenter,:)); 
    Groups = reshape(Groups, nPixV, nPixH);
end

% toc

WaitBarPerso(0.90, hObject, eventdata, handles);
drawnow


% variables sending: 
handles.MaskFile(OnEcritMaskFile).type = 1;
handles.MaskFile(OnEcritMaskFile).Pixels = CenterPixels;
handles.MaskFile(OnEcritMaskFile).Nb = NbMask;
handles.MaskFile(OnEcritMaskFile).Name = Name;
handles.MaskFile(OnEcritMaskFile).Mask = Groups;
handles.MaskFile(OnEcritMaskFile).NameMinerals = NameMinerals;


Compt = 1;
for i=1:length(handles.MaskFile(:))
	if handles.MaskFile(Compt).type == 1
    	ListNameMen(Compt) = handles.MaskFile(i).Name;
        Compt = Compt+1;
    end
end
set(handles.PPMenu3,'String',ListNameMen)
set(handles.PPMenu3,'Value',OnEcritMaskFile) % currently selected. 
    
% --------------------------------------
% Update the menu "Mineral":
set(handles.PPMenu2,'String',NameMinerals)

% --------------------------------------
% DISPLAY MASKS
MaskButton2_Callback(hObject, eventdata, handles);

% --------------------------------------
% Statistics:
for i=2:length(NameMinerals)
    Temp4Sum = Groups == i-1;
    NbTot(i-1) = sum(Temp4Sum(:));
end
for i=1:length(NbTot)
    PerTot(i) = NbTot(i)/sum(NbTot)*100;
end

disp(['Mask creating ... (',char(Name),') ...']);
disp(['Mask creating ... (Selected maps: ',char(ConcatMapName),')']);
disp(['Mask creating ... (Nb Masks: ',num2str(NbMask),')']);
for i=1:length(CenterPixels(:,1))
    disp(['Mask creating ... (Selected Pixels: ',char(num2str(i)),' Coordinates: ',char(num2str(CenterPixels(i,1))),'/',char(num2str(CenterPixels(i,2))),'']);
end
disp(['Mask creating ... (Method: ',char(Method),')']);
for i=2:length(NameMinerals)
    disp(['Mask creating ... (Phase: ',num2str(i-1),' name: ',char(NameMinerals(i)),' < ',num2str(PerTot(i-1)),'% >)']);
end
disp(['Mask creating ... (',char(Name),') ... Ok']);
disp(' ');

CodeTxt = [7,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Name),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(5)),' (',char(Name),')']);

WaitBarPerso(1, hObject, eventdata, handles);
drawnow

set(gcf, 'WindowButtonMotionFcn', @mouseMove);

guidata(hObject, handles); 
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     RENAME MINERALS V1.4.1
function MaskButton3_Callback(hObject, eventdata, handles)
NumMask = get(handles.PPMenu3,'Value'); % MaskGroup selected
MaskFile = handles.MaskFile;

NbMask = MaskFile(NumMask).Nb;
NameList = MaskFile(NumMask).NameMinerals;
AncList = NameList;
Name = MaskFile(NumMask).Name;

MaskButton2_Callback(hObject, eventdata, handles); % dislay the mask map

CodeTxt = [7,6];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(6))]);

for i=1:NbMask, EnTete(i,:) = {'Name:'}; end

OutputInput = inputdlg(EnTete,'Names change',1,NameList(2:end));

if ~length(OutputInput) % V1.4.1
    CodeTxt = [7,10];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

NameList(2:end) = OutputInput;
MaskFile(NumMask).NameMinerals = NameList;

handles.MaskFile = MaskFile;
guidata(hObject,handles);

% Update the list:
set(handles.PPMenu2,'String',NameList)

disp(['Mask editing ... (',char(Name),') ... ']);
for i=2:length(NameList)
    disp(['Mask editing ... (',num2str(i-1),' rename: ',char(AncList(i)),' --> ',char(NameList(i)),')']);
end
disp(['Mask editing ... (',char(Name),') ... Ok']);
disp(' ');

% --------------------------------------
% DISPLAY MASKS
MaskButton2_Callback(hObject, eventdata, handles);


CodeTxt = [7,7];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(7))]);

guidata(hObject,handles);
return


% #########################################################################
%     CHANGE THE MASK FILE V1.4.1
function PPMenu3_Callback(hObject, eventdata, handles)

MaskFile = handles.MaskFile;

OnEstOu = get(hObject,'Value');
Liste = get(hObject,'String');
Name = Liste(OnEstOu);

ListeMin = handles.MaskFile(OnEstOu).NameMinerals;
set(handles.PPMenu2,'String',ListeMin);
set(handles.PPMenu2,'Value',1);



CodeTxt = [7,8];
set(handles.TxtControl,'String',[char(Name),' ',char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(Name),' ',char(handles.TxtDatabase(7).txt(8))]);
MaskButton2_Callback(hObject, eventdata, handles);


guidata(hObject, handles);
return
% --- Executes during object creation, after setting all properties.
function PPMenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% #########################################################################
%     DELETE THE SELECTED MASK FILE V1.5.4
function MaskButton5_Callback(hObject, eventdata, handles)

% Changes for associated menus 
handles.currentdisplay = 1; % Input change
set(handles.QUppmenu2,'Value',1); % Input Change
set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0);

% new function 08/11/2012
MaskFile = handles.MaskFile;

Delete = get(handles.PPMenu3,'Value');
DelList = get(handles.PPMenu3,'String');
DelName = DelList(Delete);


if Delete == 1 % on enleve le premier maskfile
    for k = 1:length(DelList) - 1
        NewMaskFile(k) = MaskFile(k+1);
        NewMaskListe(k) = DelList(k+1);
    end
end
if Delete > 1 && Delete < length(DelList) % On enleve un au milieu
    for k = 1:(Delete - 1)
        NewMaskFile(k) = MaskFile(k);
        NewMaskListe(k) = DelList(k);
    end
    for k = Delete:length(DelList)-1
        NewMaskFile(k) = MaskFile(k+1);
        NewMaskListe(k) = DelList(k+1);
    end

end
if Delete == length(DelList) % on enleve le dernier
    for k = 1:length(DelList) - 1
        NewMaskFile(k) = MaskFile(k);
        NewMaskListe(k) = DelList(k);
    end
    
end

set(handles.PPMenu3,'String',NewMaskListe)
set(handles.PPMenu3,'Value',1)
 
handles.MaskFile = NewMaskFile;


CodeTxt = [7,11];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(DelName),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  

disp(['Deleting ... (MaskFile: ',char(DelName),') ... Ok']); disp(' ');

% Display the first maskfile
PPMenu3_Callback(hObject, eventdata, handles);

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
GraphStyle(hObject, eventdata, handles)
return


% #########################################################################
%     EXPORT THE MASK MAP V1.4.1
function MaskButton4_Callback(hObject, eventdata, handles)
NumMask = get(handles.PPMenu3,'Value');
Liste = get(handles.PPMenu3,'String');
Name = Liste(NumMask);
MaskFile = handles.MaskFile;

Mask4Display = MaskFile(NumMask).Mask;
NbMask = MaskFile(NumMask).Nb;
NameMask = MaskFile(NumMask).NameMinerals;

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    Mask4Display = Mask4Display.*handles.corrections(1).mask;
end

figure,
imagesc(XimrotateX(Mask4Display,handles.rotateFig)), axis image, colormap(hsv(NbMask)); %colormap(jet(NbMask))
set(gca,'xtick',[], 'ytick',[]); 

if get(handles.CorrButtonBRC,'Value')
    colormap([0,0,0;hsv(NbMask)])
    hcb = colorbar('YTickLabel',NameMask); caxis([0 NbMask+1]);
    set(hcb,'YTickMode','manual','YTick',[0.5:1:NbMask+1]);
else
    colormap(hsv(NbMask))
    hcb = colorbar('YTickLabel',NameMask(2:end)); caxis([1 NbMask+1]);
    set(hcb,'YTickMode','manual','YTick',[1.5:1:NbMask+1]);
end
title(Name)

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
return


% #########################################################################
%     EXPORT MASK PROPORTIONS (New V2.1.1)
function MaskButton6_Callback(hObject, eventdata, handles)

NumMask = get(handles.PPMenu3,'Value');
Liste = get(handles.PPMenu3,'String');
Name = Liste(NumMask);
MaskFile = handles.MaskFile;

Mask4Display = MaskFile(NumMask).Mask;
NbMask = MaskFile(NumMask).Nb;
NameMask = MaskFile(NumMask).NameMinerals;

Occurences = zeros(NbMask,1);

for i=1:NbMask
    Occurences(i) = length(find(Mask4Display(:) == i));
end

ModalAdundances = Occurences/sum(Occurences)*100;
   

% Save
CodeTxt = [7,15];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(12).txt(7))]);

[Success,Message,MessageID] = mkdir('Exported-PhaseProportions');

cd Exported-PhaseProportions
[Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export file as');
cd ..

if ~Directory
    CodeTxt = [12,8];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
	return
end


fid = fopen(strcat(pathname,Directory),'w');
fprintf(fid,'%s\n','Phase proportions (wt.%) from XMapTools');
fprintf(fid,'%s\n',date);
fprintf(fid,'%s\n\n\n',['Maskfile: ',char(Name)]);

fprintf(fid,'%s\n','---------------------------------');
fprintf(fid,'%s\t\t%s\t%s\n','Phase','Prop (%)','Nb Pixels');
fprintf(fid,'%s\n','---------------------------------');
for i = 1:length(ModalAdundances)
    if length(char(NameMask{i+1})) > 4
        fprintf(fid,'%s%s\t%.2f\t\t%.0f\n',char(NameMask{i+1}),': ',ModalAdundances(i),Occurences(i));
    else
        fprintf(fid,'%s%s\t\t%.2f\t\t%.0f\n',char(NameMask{i+1}),': ',ModalAdundances(i),Occurences(i));
    end
end
fprintf(fid,'%s\n','---------------------------------');

fprintf(fid,'\n\n');
fclose(fid);

CodeTxt = [7,16];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);



return


% #########################################################################
%     BUIL/IMPORT MASKFILE (New V2.1.1)
function MaskButton7_Callback(hObject, eventdata, handles)
% 

CodeTxt = [7,17];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

[Success,Message,MessageID] = mkdir('Maskfiles');

cd Maskfiles
[FileName,PathName,FilterIndex] = uigetfile({'*.txt;','Maskfiles (*.txt)';'*.*',  'All Files (*.*)'},'Pick file(s)','MultiSelect', 'on');
cd ..

if ~FilterIndex
    CodeTxt = [7,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    return
end

CodeTxt = [7,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

if iscell(FileName)
    % -------- Merge -------- 
    
    NameMask{1} = 'none';
    
    RawMapSizeRef = size(handles.data.map(1).values);
    NbMask = 0;
    NewMaskFile = zeros(RawMapSizeRef);
    
    WaitBarPerso(0, hObject, eventdata, handles);
    
    for i=1:length(FileName)
        
        WaitBarPerso(i/length(FileName), hObject, eventdata, handles);
        
        DataTemp = load([PathName,FileName{i}]);
        NbNewMask = max(DataTemp(:))-1;
        
        if ~isequal(size(DataTemp),RawMapSizeRef)
            errordlg({'The maskfile size is not the same than the maps.'},'Error');
            
            CodeTxt = [7,4];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            return
        end
        
        for j=1:NbNewMask
            WhereOK = find(DataTemp == j+1);
            NbMask = NbMask+1;
            
            
            NameCrunched = FileName{i}; 
            NameCrunched = NameCrunched(1:end-4);
            NameMask{NbMask+1} = [NameCrunched,'-',num2str(j)];
            
            NewMaskFile(WhereOK) = NbMask.*ones(length(WhereOK),1);            
        end
    end
    
    % We are looking for 0 into the new maskfile
    WhereOK = find(NewMaskFile == 0);
    
    if length(WhereOK)
        NbMask = NbMask+1;
        NameMask{NbMask+1} = ['Unselected pixels'];
        NewMaskFile(WhereOK) = NbMask.*ones(length(WhereOK),1);
    end
    
    CodeTxt = [7,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  
    
    Name = inputdlg('Mask file name','define a name',1,{['Merged-Maskfile']});

    if length(Name) == 0
        CodeTxt = [7,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles); 

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(4))]);
        return
    end
    
    
else
    % --------  Load -------- 
    NameMask{1} = 'none';
    
    RawMapSizeRef = size(handles.data.map(1).values);
    NbMask = 0;
    NewMaskFile = zeros(RawMapSizeRef);
    
    WaitBarPerso(0, hObject, eventdata, handles);    
    WaitBarPerso(0.5, hObject, eventdata, handles);
        
    DataTemp = load([PathName,FileName]);
    NbNewMask = max(DataTemp(:))-1;
        
    if ~isequal(size(DataTemp),RawMapSizeRef)
        errordlg({'The maskfile size is not the same than the maps.'},'Error');

        CodeTxt = [7,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        return
    end

    for j=1:NbNewMask
        WhereOK = find(DataTemp == j+1);
        NbMask = NbMask+1;

        NameMask{NbMask+1} = [FileName(1:end-4),'-',num2str(j)];

        NewMaskFile(WhereOK) = NbMask.*ones(length(WhereOK),1);            
    end
    
    % We are looking for 0 into the new maskfile
    WhereOK = find(NewMaskFile == 0);
    
    if length(WhereOK)
        NbMask = NbMask+1;
        NameMask{NbMask+1} = ['Unselected pixels'];
        NewMaskFile(WhereOK) = NbMask.*ones(length(WhereOK),1);
    end
    
    WaitBarPerso(1, hObject, eventdata, handles);
    
    CodeTxt = [7,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);  
    
    Name = inputdlg('Mask file name','define a name',1,{['Imported-Maskfile']});

    if length(Name) == 0
        CodeTxt = [7,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles); 

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(7).txt(4))]);
        return
    end
    
end

% -------- Save and display the new maskfile -------- 

if handles.MaskFile(1).type
    Where = length(handles.MaskFile)+1;
else
    Where = 1;
end

handles.MaskFile(Where).type = 1;
handles.MaskFile(Where).Pixels = [];
handles.MaskFile(Where).Nb = NbMask;
handles.MaskFile(Where).Name = Name;
handles.MaskFile(Where).Mask = NewMaskFile;
handles.MaskFile(Where).NameMinerals = NameMask;

% --------------------------------------
% Statistics:
for i=2:length(NameMask)
    Temp4Sum = NewMaskFile == i-1;
    NbTot(i-1) = sum(Temp4Sum(:));
end
PerTot = NbTot./(sum(NbTot))*100;

disp(['Mask importing ... (',char(Name),') ...']);
disp(['Mask importing ... (Nb Masks: ',num2str(NbMask),')']);
for i=2:length(NameMask)
    disp(['Mask importing ... (Phase: ',num2str(i-1),' name: ',char(NameMask(i)),' < ',num2str(PerTot(i-1)),'% >)']);
end
disp(['Mask importing ... (',char(Name),') ... Done']);
disp(' ');


Compt = 1;
for i=1:length(handles.MaskFile(:))
	if handles.MaskFile(Compt).type == 1
    	ListNameMen(Compt) = handles.MaskFile(i).Name;
        Compt = Compt+1;
    end
end
set(handles.PPMenu3,'String',ListNameMen)
set(handles.PPMenu3,'Value',Where) % currently selected. 

% --------------------------------------
% Update the menu "Mineral":
set(handles.PPMenu2,'String',NameMask)

% --------------------------------------
% DISPLAY MASKS
MaskButton2_Callback(hObject, eventdata, handles);

CodeTxt = [7,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Name),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

WaitBarPerso(1, hObject, eventdata, handles);
drawnow

guidata(hObject, handles); 
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     GRAIN BOUNDARY ORIENTATION (New V2.1.3)
function MaskButton8_Callback(hObject, eventdata, handles)
%

% this function is available only if we computed a BRC correction
% TEMPORARY CHECK !!!
if ~handles.corrections(1).value   % BRC
    return
end

TheBoundaries = zeros(size(handles.corrections(1).mask));
WhichOnes = find(handles.corrections(1).mask(:) == 0);
TheBoundaries(WhichOnes) = ones(size(WhichOnes));

SParams = inputdlg({'Half-size (in px; <=4)'},'GBO parameters',1,{'2'});

HalfSize = str2num(SParams{1});


% Initialization
PositionOri = [HalfSize+1,HalfSize+1];
MatrixCompOri = zeros(2*HalfSize+1);
MatrixCompOri(:,HalfSize+1) = ones(2*HalfSize+1,1);

NbComp = HalfSize*(HalfSize+1)/2;
% Here the Gauss method is used to estimate the number of computations that
% should be made for each of the fourth computation blocs. Note that the
% first is horizontal, the second and the third are vertical and the fourth
% is again horizontal (in the other direction). 

Indices = 1:4*NbComp; % 0 and 180 are the same

CompType = zeros(size(Indices));
CompType(1:NbComp) = 1*ones(1,NbComp);
CompType(NbComp+1:2*NbComp) = 2*ones(1,NbComp);
CompType(2*NbComp+1:3*NbComp) = 3*ones(1,NbComp);
CompType(3*NbComp+1:4*NbComp) = 4*ones(1,NbComp);

FractD = 180/(4*NbComp);
OrientationsD = (Indices-1)*FractD;

% Computation
% we are working between [Halfsize+1:end-HalfSize,Halfsize+1:end-HalfSize]

FinalMapDegree = zeros(size(TheBoundaries));
FinalMapCounts = zeros(size(TheBoundaries));

% figure
for i=1:length(OrientationsD)
    
    [MatrixComp] = MatrixComTransformMax4(MatrixCompOri,CompType,i);
    
    [TheY,TheX] = find(MatrixComp);
    
    TempMaps = zeros(size(TheBoundaries)); %zeros(size(TheBoundaries,1)-2*HalfSize,size(TheBoundaries,2)-2*HalfSize);
    for iShift = 1:length(TheY)
        
        Xmin = TheX(iShift);
        Xmax = size(TheBoundaries,2)-(length(MatrixComp)-Xmin);
        
        Ymin = TheY(iShift);
        Ymax = size(TheBoundaries,1)-(length(MatrixComp)-Ymin);

        TheMapSel = TheBoundaries(Ymin:Ymax,Xmin:Xmax);
        %size(TheMapSel)

        TempMaps(HalfSize+1:end-HalfSize,HalfSize+1:end-HalfSize) = TempMaps(HalfSize+1:end-HalfSize,HalfSize+1:end-HalfSize) + TheMapSel;
    end
    
    WhereSolu = find(TempMaps == iShift);
    
    FinalMapDegree(WhereSolu) = FinalMapDegree(WhereSolu)+OrientationsD(i)*ones(size(WhereSolu));
    FinalMapCounts(WhereSolu) = FinalMapCounts(WhereSolu)+ones(size(WhereSolu));
    
    %imagesc(MatrixComp),axis image, colorbar
    %pause(0.2)
    
end

FinalMapDegree(find(FinalMapDegree == 0)) = -10*ones(size(find(FinalMapDegree == 0)));

FinalMapDegree = FinalMapDegree./FinalMapCounts;



figure, imagesc(FinalMapDegree), axis image, colorbar, colormap([[0,0,0];jet(64);[0,0,0]])
caxis([-2 182])

figure, hist(FinalMapDegree(find(FinalMapDegree>=0)),30);



% Here maybe a new interface ???


% if many solutions for a pixel, take the average in degree...



  


%keyboard


return


function [MatrixComp] = MatrixComTransformMax4(MatrixCompOri,CompType,Ind);
%     
%

% Ind is the indice and Typ is the type of transformation (could be
% 1, 2, 3 or 4)
clc
MatrixComp = MatrixCompOri;

HalfSize = (size(MatrixCompOri,1)-1)/2;

% We apply all the transformations
DistY = HalfSize;
DistX = HalfSize;

Ymax = 2*HalfSize+1;
Xmax = Ymax;

Compt = 1;


% CASE 1 // right (+1)

Yi = 1;
while Yi <= DistY

    TheHorizVect = MatrixComp(Yi,:);
    OldPos = find(TheHorizVect);

    TheNextHorizVect = MatrixComp(Yi+1,:);
    NextHorizPos = find(TheNextHorizVect);

    if OldPos < Ymax && OldPos == NextHorizPos
        % we move here
        Compt = Compt+1;
        MatrixComp(Yi,OldPos) = 0;
        MatrixComp(Yi,OldPos+1) = 1;

        MatrixComp((Ymax+1)-Yi,(Xmax+1)-OldPos) = 0;
        MatrixComp((Ymax+1)-Yi,(Xmax+1)-OldPos-1) = 1;


        MatrixComp;
        
        if isequal(Compt,Ind)
            return
        end
        
        Yi = Yi+1;
        
        if MatrixComp(Yi+1,OldPos-1)
            Yi=1;
        end
        
    else
        break
    end
end

 
% CASE 2 // Bottom (+1)
  
Xi = Xmax;
while Xi >= DistX

    TheVertVect = MatrixComp(:,Xi);
    OldPos = find(TheVertVect);

    TheNextVertVect = MatrixComp(:,Xi-1);
    NextVertPos = find(TheNextVertVect);

    if OldPos < Xmax-HalfSize && OldPos == NextVertPos-1
        % we move here
        Compt = Compt+1;
        MatrixComp(OldPos,Xi) = 0;
        MatrixComp(OldPos+1,Xi) = 1;

        MatrixComp((Ymax+1)-OldPos,(Xmax+1)-Xi) = 0;
        MatrixComp((Ymax+1)-OldPos-1,(Xmax+1)-Xi) = 1;


        MatrixComp;
        
        if isequal(Compt,Ind)
            return
        end

        Xi = Xi-1;

        if MatrixComp(OldPos+1,Xi-1)
            Xi = Xmax;
        end
        
    else
        break
    end
end

% CASE 3 // Bottom (+1)
  
Xi = Xmax;
while Xi >= DistX

    TheVertVect = MatrixComp(:,Xi);
    OldPos = find(TheVertVect);

    TheNextVertVect = MatrixComp(:,Xi-1);
    NextVertPos = find(TheNextVertVect);

    if OldPos < Xmax && OldPos == NextVertPos
        % we move here
        Compt = Compt+1;
        MatrixComp(OldPos,Xi) = 0;
        MatrixComp(OldPos+1,Xi) = 1;

        MatrixComp((Ymax+1)-OldPos,(Xmax+1)-Xi) = 0;
        MatrixComp((Ymax+1)-OldPos-1,(Xmax+1)-Xi) = 1;


        MatrixComp;
        
        if isequal(Compt,Ind)
            return
        end

        Xi = Xi-1;

        if MatrixComp(OldPos-1,Xi-1)
            Xi=Xmax;
        end

    else
        break
    end
end

% CASE 4 // Left (+1)

Yi = Ymax;
while Yi >= DistY+1

    TheHorizVect = MatrixComp(Yi,:);
    OldPos = find(TheHorizVect);

    TheNextHorizVect = MatrixComp(Yi-1,:);
    NextHorizPos = find(TheNextHorizVect);

    if OldPos > HalfSize+1 && OldPos == NextHorizPos+1
        % we move here
        Compt = Compt+1;
        MatrixComp(Yi,OldPos) = 0;
        MatrixComp(Yi,OldPos-1) = 1;

        MatrixComp((Ymax+1)-Yi,(Xmax+1)-OldPos) = 0;
        MatrixComp((Ymax+1)-Yi,(Xmax+1)-OldPos+1) = 1;


        MatrixComp;
        
        if isequal(Compt,Ind)
            return
        end

        Yi = Yi-1;

        if MatrixComp(Yi-1,OldPos-1)
            Yi=Xmax;
        end

    else
        break
    end
end

return




% #########################################################################
%     CORRECTION OF PROBE INTENSITY
function PIButton1_Callback(hObject, eventdata, handles)
% WARNING, this function is a test version. 

ButtonName = questdlg('Temporary test function. Do you want to continue ?', ...
'Warning');
if length(ButtonName) ~= 3
    return
end

Data = handles.data;
MaskFile = handles.MaskFile;
ListMap = handles.ListMap;

MapRef = get(handles.PPMenu1,'Value');

MapSelected = Data.map(MapRef).values;
RefMapSelected = Data.map(MapRef).ref;
MaskSelected = get(handles.PPMenu3,'Value');

Mineral = get(handles.PPMenu2,'Value');

if Mineral == 1
    warndlg('Please select a mineral','Cancelation');
    return
end

% Just to display, the correction modify the MapSelected value. 
if Mineral > 1
    RefMin = Mineral - 1;
    AAfficher = MaskFile(MaskSelected).Mask == RefMin;
    AAfficher = Data.map(MapRef).values .* AAfficher;
    
else
    AAfficher = Data.map(MapRef).values;
end

% --------------------------------
% figure:
figure(5), 
imagesc(AAfficher), axis image, colorbar vertical, hold on

zoom on                                                         % New 1.6.2

Min = get(handles.ColorMin,'String');
Max = get(handles.ColorMax,'String');
if str2num(Max) > str2num(Min)
    caxis([str2num(Min) str2num(Max)]);
end
% Value = get(handles.checkbox1,'Value');
% if Value == 1
%     colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end


% --------------------------------
% Selection:
clique = 1; ComptSelect = 1;
while clique < 2
	[SelPixel(1),SelPixel(2),clique] = XginputX(1,handles); % On selectionne le pixel
	if clique < 2
    	CenterPixels(ComptSelect,:) = round(SelPixel);
    	plot(CenterPixels(:,1),CenterPixels(:,2), 'mo','linewidth', 2)
    	ComptSelect = ComptSelect+1;
    end
end


% --------------------------------
% Display and select the correction
XAll = CenterPixels(:,2);
for i=1:length(XAll)
    Element(i) = MapSelected(CenterPixels(i,2),CenterPixels(i,1)); % L/C -> Y/X
end

figure(6), plot(XAll,Element,'ok'), hold on


clique = 1; ComptPts = 1;
while clique < 2
	[SelPixel(1),SelPixel(2),clique] = XginputX(1,handles); % On selectionne le pixel
	if clique < 2
    	InterpolPixels(ComptPts,:) = round(SelPixel);
    	plot(InterpolPixels(:,1),InterpolPixels(:,2), '-+r','linewidth', 2)
    	ComptPts = ComptPts+1;
    else
        break
    end
end

close(5),close(6)

% --------------------------------
% Inpertolation 
X = InterpolPixels(:,1); Y = InterpolPixels(:,2);
IntX = 1:1:length(AAfficher(:,1));
IntY = interp1(X,Y,IntX,'cubic');

figure(5), plot(XAll,Element,'ok'), hold on, plot(IntX,IntY,'-r');
title('Interpolated deviation');

% --------------------------------
% Correction Factor:
MeanValue = mean(IntY);
CorrFactor = MeanValue ./ IntY; % vector

ProvCorr = Data.map(MapRef).values;


% --------------------------------
% Element selection :
InitVal(1) = MapRef;

ElSelected = listdlg('ListString',ListMap,'SelectionMode','multiple','InitialValue',InitVal,'Name','Select your elements');

for i=1:length(ElSelected)
    OnSelect = ElSelected(i);
    ProvCorr = Data.map(OnSelect).values;
    ProvName = strcat(Data.map(OnSelect).name,'_Corr');
    ProvType = 1; % modification of type maybe in a new version
    for j=1:length(ProvCorr(:,1))
        ProvCorr(j,:) = ProvCorr(j,:) .* CorrFactor(j);
    end
    
    ProvCorr = round(ProvCorr);
    
    % Save:
    OnRemplace = 0;
    for k=1:length(Data.map(:))
        if Data.map(k).type == 0
            OnRemplace = 1;
            break
        end
    end
	if OnRemplace == 0
        k = k+1; % add a new line
    end
    
    Data.map(k).type = ProvType; 
    Data.map(k).name = ProvName; % Name
    Data.map(k).values = ProvCorr;
    Data.map(k).ref = RefMapSelected; % Element Ref
            
    Compt = 1; 
    for k=1:length(Data.map(:)), if Data.map(k).type == 1, ListMap(Compt) = Data.map(k).name; Compt = Compt + 1; end, end
    
    set(handles.PPMenu1,'string',ListMap);
    set(handles.PPMenu1,'Value',i)

    handles.data = Data; % send
    handles.ListMap = ListMap;
    
    SiResidu = Data.map(MapRef).values - ProvCorr;
    SiCorrPercent = (Data.map(MapRef).values - ProvCorr)./(Data.map(MapRef).values.*100);

    figure, subplot(1,2,1)
    colormap(jet(64));
    imagesc(SiResidu), axis image, colorbar horizontal
	title('carte des residus')
    subplot(1,2,2)
    imagesc(SiCorrPercent), axis image, colorbar horizontal
    title('Ecart de la carte corrigee pap à brute (%)')
    
end

% ------------------------------
% Display tools :
close(5)

guidata(hObject,handles);


% #########################################################################
%     OLD LOAD A STD FILE (PROFIL) V1.4.1   SAUVEGARDE
function SAVE___PRButton1_Callback(hObject, eventdata, handles)
NameMaps = handles.NameMaps;
Data = handles.data;

% On supprime les profils précédement chargés...
handles.profils = [];

CodeTxt = [8,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(1))]);

[FileName,PathName,FilterIndex] = uigetfile({'*.txt;*.asc;*.dat;','Maps Files (*.txt, *.asc, *.dat)';'*.*',  'All Files (*.*)'},'Pick a file');

if FilterIndex
    CodeTxt = [8,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(3))]);
    fid = fopen(strcat(PathName,FileName)); 
    DefOrder=[];
    DefProfils=[];
    DefMap = [];
    LectureOrder = 0;
    LectureProfils = 0;
    LectureMap = 0;
    
    ComptLignProfils = 0;
    ComptLignMap = 0;
    
    while 1
        tline = fgets(fid);
        if ~ischar(tline)
            break
        end
        prose = strread(tline,'%s','delimiter','\r');
        AlireMap = ismember('*** Map coordinates ***',prose);
        AlireOrder = ismember('*** Elements order ***',prose);
        AlireProfils = ismember('*** Analysis ***',prose);
        
        if AlireMap, LectureMap = 1; end
        if AlireOrder, LectureOrder = 1; end
        if AlireProfils, LectureProfils = 1; end
        
        if size(tline)<=[1,2], LectureOrder = 0; LectureProfils = 0; LectureMap = 0; end,
        
        if LectureOrder && ~AlireOrder, DefOrder = [DefOrder,prose]; end,
        if LectureProfils && ~AlireProfils, 
            ComptLignProfils=ComptLignProfils+1; 
            tampon = strread(char(tline),'%f','delimiter','\t');
            DefProfils(ComptLignProfils,:) = tampon(:);
        end 
        if LectureMap && ~AlireMap, 
            ComptLignMap=ComptLignMap+1; 
            tampon = strread(char(tline),'%f','delimiter','\t');
            DefMap(ComptLignMap,:) = tampon(:);
        end 
    end 
    
    ListPrElements = strread(char(DefOrder),'%s','whitespace',' ');

    % first test: 
    OkV = 1;
    
else
    CodeTxt = [8,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(2))]);
    return
end 


%keyboard

if size(DefProfils,2) == length(ListPrElements)
    
    % work:
    ForDetection = NameMaps.oxydes;
    ForDetection(end+1:end+2) = {'X','Y'};
    
    ForIndexation = NameMaps.elements;
    ForIndexation(end+1:end+2) = {'X','Y'};
    
    [IsM,RefElemPro] = ismember(ListPrElements,ForDetection);
    if sum(IsM) ~= length(IsM)
        % Problem of correspondence between the elements of database and entries of profils... 
        set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
        
        CodeTxt = [8,5];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(5))]);
        guidata(hObject,handles);
        return
    end
        
    ListPrElements = ForIndexation(RefElemPro); % New order
       
    [isX,XRef] = ismember('X',ListPrElements);
    [isY,YRef] = ismember('Y',ListPrElements);
     
    if isX+isY ~= 2
        % Coordinates (X,Y) were not detected
        set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
        
        CodeTxt = [8,6];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(6))]);
        guidata(hObject,handles);
        return
    end
    
    handles.profils.coord(:,1) = DefProfils(:,XRef); 
    handles.profils.coord(:,2) = DefProfils(:,YRef);
    
    % Organisation des données
    % NameOrder contient la liste de tous les éléments disponibles dans le
    % fichier profil. 
    for i=1:length(ListPrElements)
        if i == XRef || i == YRef
            continue
        else
            DataPro(:,i) = DefProfils(:,i);
            NameOrder(i) = ListPrElements(i);
        end
    end

    Concat = strcat(' (',NameOrder(1)); 
    for i=2:length(NameOrder), 
        Concat = strcat(Concat,'-',ListPrElements(i)); 
    end, 
    Concat = strcat(Concat,')');
    
    
    
    %keyboard
    
    Xleft = DefMap(1); Xright = DefMap(2); Ybot = DefMap(3); Ytop = DefMap(4);
    SizeMap = size(Data.map(1).values);
    
    SizeXPixel = abs((Xleft - Xright) / (SizeMap(2) -1 )); % x --> col
    SizeYPixel = abs((Ytop - Ybot) / (SizeMap(1) -1 )); % x --> line
    
    % new profile coordonate computation
    if Xleft < Xright    
        XCoo = Xleft : SizeXPixel : Xright;
    else
        XCoo = Xleft : -SizeXPixel : Xright;
    end
    if Ytop > Ybot
        YCoo = Ytop : -SizeYPixel : Ybot;
    else
        YCoo = Ytop : SizeYPixel : Ybot;
    end
    
    IdxAllPr = NaN * zeros(length(DefProfils(:,1)), 2);

    
    for i = 1 : length(DefProfils(:,1))
    	[V(i,1), IdxAllPr(i,1)] = min(abs(XCoo-DefProfils(i,XRef))); % Index X
    	[V(i,2), IdxAllPr(i,2)] = min(abs(YCoo-DefProfils(i,YRef))); % Index Y
    end
    
    handles.profils.xcoo = XCoo;
    handles.profils.ycoo = YCoo; % new option (for correction)
    handles.profils.idxallpr = IdxAllPr;
    handles.profils.data = DataPro;
    handles.profils.elemorder = NameOrder;
    handles.profils.display = strcat(FileName,Concat);
    
    disp(['Profile setting ... (',char(FileName),') ...']);
    disp(['Profile setting ... (Elements: ',char(Concat),')']);
    disp(['Profile setting ... (Analysis: ',num2str(length(DataPro)),')']);
    disp(['Profile setting ... (Validity: ',char(num2str(IsM')),')']);
    disp(['Profile setting ... (',char(FileName),') ... Ok']);
    disp(' ')
    
    set(handles.PRAffichage1,'String',strcat(FileName,Concat));
    
    CodeTxt = [8,7];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(FileName),')']); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(7)),' (',char(FileName),')']);
    
else
    set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
    
    CodeTxt = [8,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(4))]);
    return
end

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)

% display profils into the map
PRButton3_Callback(hObject, eventdata, handles)
return


% #########################################################################
%     LOAD A FILE (STANDARDS) V2.1.3
function PRButton1_Callback(hObject, eventdata, handles)
NameMaps = handles.NameMaps;
Data = handles.data;

% On supprime les profils précédement chargés... si jamais
handles.profils = [];

CodeTxt = [8,1]; % Select a file
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(1))]);

% - - - Update 2.1.4 - Automatic opening of Classification.txt
WhereWheAre = cd;
PathName = [WhereWheAre,'/'];
FileName = 'Standards.txt';

if isequal(exist([PathName,FileName],'file'),2)
    ButtonName = questdlg('Would you like to used Standards.txt?','Standards','Yes');  
    switch ButtonName
        case 'Yes'
            Question = 0;
        otherwise
            Question = 1;
    end         
else
    Question = 1;
end

if Question
    [FileName,PathName,FilterIndex] = uigetfile({'*.txt;*.asc;*.dat;','Maps Files (*.txt, *.asc, *.dat)';'*.*',  'All Files (*.*)'},'Pick a file');
else
    FilterIndex = 1;
end

% --

if FilterIndex % UPDATED 1.6.1 (P. Lanari - 28/12/12)
    CodeTxt = [8,3]; % Profile file opening
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
    Compt = 0;
    
    DefMap = [];
    ListPrElements = [];
    DefProfils = [];
    
    % Load
    fid = fopen(strcat(PathName,FileName));
    while 1
        tline = fgets(fid);
        if ~ischar(tline)   % end of this file...
            break
        end
        
        if isequal(tline(1),'>')
            leCase = str2num(tline(2));
            switch leCase
                
                case 1 % map coordinates
                    tline = fgets(fid);
                    DefMap = strread(tline);
                    
                case 2 % elements order
                    tline = fgets(fid);
                    ListPrElements = strread(tline, '%s');
                    
                case 3 % Point mode analyses
                    while 1
                        tline = fgets(fid);
                        if length(tline) < 3
                            break
                        end
                        Compt = Compt+1;
                        DefProfils(Compt,:) = strread(tline);
                    end
            end       
        end
        
        
        
    end
    
else
    CodeTxt = [8,2]; % end of execution
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    return
end 
   

if size(DefProfils,2) == length(ListPrElements)
    
    % work:
    ForDetection = NameMaps.oxydes;
    ForDetection(end+1:end+2) = {'X','Y'};
    
    ForIndexation = NameMaps.elements;
    ForIndexation(end+1:end+2) = {'X','Y'};
    
    [IsM,RefElemPro] = ismember(ListPrElements,ForDetection);
    if sum(IsM) ~= length(IsM)
        % Problem of correspondence between the elements of database and entries of profils... 
        set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
        
        CodeTxt = [8,5];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(5))]);
        guidata(hObject,handles);
        return
    end
        
    ListPrElements = ForIndexation(RefElemPro); % New order
       
    [isX,XRef] = ismember('X',ListPrElements);
    [isY,YRef] = ismember('Y',ListPrElements);
     
    if isX+isY ~= 2
        % Coordinates (X,Y) were not detected
        set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
        
        CodeTxt = [8,6];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(6))]);
        guidata(hObject,handles);
        return
    end
    
    handles.profils.coord(:,1) = DefProfils(:,XRef); 
    handles.profils.coord(:,2) = DefProfils(:,YRef);
    
    handles.profils.pointselected = ones(size(handles.profils.coord,1),1);
    
    % Organisation des données
    % NameOrder contient la liste de tous les éléments disponibles dans le
    % fichier profil. 
    for i=1:length(ListPrElements)
        if i == XRef || i == YRef
            continue
        else
            DataPro(:,i) = DefProfils(:,i);
            NameOrder(i) = ListPrElements(i);
        end
    end

    Concat = strcat(' (',NameOrder(1)); 
    for i=2:length(NameOrder), 
        Concat = strcat(Concat,'-',ListPrElements(i)); 
    end, 
    Concat = strcat(Concat,')');
    
    Xleft = DefMap(1); Xright = DefMap(2); Ybot = DefMap(3); Ytop = DefMap(4);
    SizeMap = size(Data.map(1).values);
    
    SizeXPixel = abs((Xleft - Xright) / (SizeMap(2) -1 )); % x --> col
    SizeYPixel = abs((Ytop - Ybot) / (SizeMap(1) -1 )); % x --> line
    
    % new profile coordonate computation
    if Xleft < Xright    
        XCoo = Xleft : SizeXPixel : Xright;
    else
        XCoo = Xleft : -SizeXPixel : Xright;
    end
    if Ytop > Ybot
        YCoo = Ytop : -SizeYPixel : Ybot;
    else
        YCoo = Ytop : SizeYPixel : Ybot;
    end
    
    IdxAllPr = NaN * zeros(length(DefProfils(:,1)), 2);

    
    for i = 1 : length(DefProfils(:,1))
    	[V(i,1), IdxAllPr(i,1)] = min(abs(XCoo-DefProfils(i,XRef))); % Index X
    	[V(i,2), IdxAllPr(i,2)] = min(abs(YCoo-DefProfils(i,YRef))); % Index Y
    end
    
    handles.profils.xcoo = XCoo;
    handles.profils.ycoo = YCoo; % new option (for correction)
    handles.profils.idxallpr = IdxAllPr;
    handles.profils.data = DataPro;
    handles.profils.elemorder = NameOrder;
    handles.profils.display = strcat(FileName,Concat);
    
    disp(['Import standard file ... (File name:',char(FileName),') ...']);
    disp(['Import standard file ... (Elements: ',char(Concat),'']);
    disp(['Import standard file ... (Number of analyses: ',num2str(length(DataPro)),')']);
    disp(['Import standard file ... (Validity: ',char(num2str(IsM')),')']);
    disp(['Import standard file ... (',char(FileName),') ... Ok']);
    disp(' ')
    
    set(handles.PRAffichage1,'String',strcat(FileName,Concat));
    
    CodeTxt = [8,7];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(FileName),')']); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(7)),' (',char(FileName),')']);
    
else
    set(handles.PRAffichage1,'String',[char(handles.TxtDatabase(8).txt(8))]);
    
    CodeTxt = [8,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(4))]);
    return
end

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)

% display profils into the map
PRButton3_Callback(hObject, eventdata, handles)
return


% #########################################################################
%     CORRECTION OF THE LOCATION. 
function PRButton2_Callback(hObject, eventdata, handles)
% ordre obligatoire : X Y (et pas Y X)
% A modifier dans une version future

ButtonName = questdlg('Temporary test function. Do you want to continue ?', ...
'Warning');
if length(ButtonName) ~= 3
    return
end

% ---------- Maps Selection ---------- 
Data = handles.data;
for i=1:length(Data.map)
    ListMap(i) = Data.map(i).name;
    ListRefMap(i) = Data.map(i).ref;
end
[SelectionMap] = listdlg('ListString',ListMap,'SelectionMode','multiple','Name','Select Maps');
LesRefsCarte = ListRefMap(SelectionMap); % Creation de LesRefsMap
LesNamesCartes = ListMap(SelectionMap);

for i=1:length(Data.map) % On test pour toutes les cartes
    a = find(LesRefsCarte-i);
    if length(a) < length(LesRefsCarte)-1;
        warndlg('You selected two of the same element...', 'Cancelation');
        return
    end
end


% ---------- Profil ref ---------- 
Profils = handles.profils;

ProfilsElem = Profils.elemorder;
ListOri = handles.NameMaps.elements;
[Ok,LesRefsPro] = ismember(ProfilsElem,ListOri); % verification et creation de LesRefsPro


% ---------- Xlag & Yag ---------- 
% setting input:
Lag = inputdlg({'X-Lag','Y-Lag'},'Input',1,{'10','10'});
XLag = str2num(char(Lag(1)));
YLag = str2num(char(Lag(2)));

for i=1:XLag*2+1
    YMapLag(:,i) = [-YLag:1:YLag]';
end
for i=1:YLag*2+1
    XMapLag(i,:) = [-XLag:1:XLag];
end

[LesLin,LesCol] = size(YMapLag);
Xmin = min(Profils.coord(:,1)); Xmax = max(Profils.coord(:,1));
Ymin = min(Profils.coord(:,2)); Ymax = max(Profils.coord(:,2));

XCoo = Profils.xcoo;
YCoo = Profils.ycoo;

% ---------- Processing ---------- 
h = waitbar(0,'Please wait...');
for iLin = 1:LesLin
    waitbar(iLin/LesLin,h);
    for iCol = 1:LesCol
        % Setting:
        LesCoor(:,1) = Profils.coord(:,1) + XMapLag(iLin,iCol);
        LesCoor(:,2) = Profils.coord(:,2) + YMapLag(iLin,iCol);
        
        % Control:
        for i=1:length(LesCoor(:,1))
            if LesCoor(i,1) < Xmin || LesCoor(i,1) > Xmax || LesCoor(i,2) < Ymin || LesCoor(i,2) > Ymax
                LesCoor(i,:) = [0,0];
            end
        end
        
        % Indexation:
        for i = 1 : length(LesCoor(:,1))
            if LesCoor(i,1) % > 0
                [V(i,1), Idx(i,1)] = min(abs(XCoo-LesCoor(i,1))); % Index X
                [V(i,2), Idx(i,2)] = min(abs(YCoo-LesCoor(i,2))); % Index Y
            else
                Idx(i,:) = [0,0];
            end
        end
        
        % Correlation
        for i=1:length(LesRefsCarte)
            LaMap = LesRefsCarte(i);
            LePro = find(LesRefsPro == LaMap); % warning, empty cell if missmatch.
            
            LesDataPro = Profils.data(:,LePro);
            for j = 1:length(LesDataPro)
                if Idx(j,1)
                    LesDataRaw(j) = Data.map(LaMap).values(Idx(j,2),Idx(j,1)); % X -> Col
                else
                    LesDataRaw(j) = 0;
                end
            end
            Correl = corrcoef(LesDataPro,LesDataRaw);
            
            Correlation(iLin,iCol,i) = Correl(1,2);
            
        end
        
    end
end

% ---------- Best correlation ---------- 
close(h)
LaSum = zeros(length(Correlation(:,1,1)),length(Correlation(1,:,1)));
for i=1:length(Correlation(1,1,:))
    LaSum = LaSum + Correlation(:,:,i);
end
figure, 
imagesc(LaSum./length(Correlation(1,1,:))), axis image, colorbar('vertical')
title('Best Corr. Average (*** left clic to change ***)')

[V,aL] = max(LaSum);
[V,bL] = max(max(LaSum));

CMax = aL(bL);
LMax = bL;

hold on, plot(LMax,CMax,'.k')

[LMaxinput,CMaxinput,Clique] = XginputX(1,handles);
if Clique < 3
    CMax = round(CMaxinput);
    LMax = round(LMaxinput);
end


% ---------- New coordonates ----------
XCorrection = XMapLag(LMax,CMax);
YCorrection = YMapLag(LMax,CMax);

LesCoordProbe(:,1) = Profils.coord(:,1) + XCorrection;
LesCoordProbe(:,2) = Profils.coord(:,2) + YCorrection;

for i=1:length(LesCoordProbe(:,1))
	if LesCoordProbe(i,1) < Xmin || LesCoordProbe(i,1) > Xmax || LesCoordProbe(i,2) < Ymin || LesCoordProbe(i,2) > Ymax
        LesCoordProbe(i,:) = [0,0];
    end
end

for i = 1 : length(LesCoordProbe(:,1))
    if LesCoordProbe(i,1) % > 0
        [V(i,1), IdxNewPr(i,1)] = min(abs(XCoo-LesCoor(i,1))); % Index X
        [V(i,2), IdxNewPr(i,2)] = min(abs(YCoo-LesCoor(i,2))); % Index Y
    else
        IdxNewPr(i,:) = [0,0];
    end
end


% ---------- Comparison ----------
[SelectionMap2] = listdlg('ListString',LesNamesCartes,'SelectionMode','multiple','Name','Select Maps');
Refs4Display = LesRefsCarte(SelectionMap2);
Names4Display = LesNamesCartes(SelectionMap2);

for i=1:length(Refs4Display)
    for j=1:length(IdxNewPr(:,1))
        if IdxNewPr(j,1)
            DataMapN(j) = Data.map(Refs4Display(i)).values(IdxNewPr(j,2),IdxNewPr(j,1));
            if Profils.idxallpr(j,1)
                DataMapO(j) = Data.map(Refs4Display(i)).values(Profils.idxallpr(j,2),Profils.idxallpr(j,1));
            else
                DataMapO(j) = 0;
            end
        elseif Profils.idxallpr(j,1)
            DataMapN(j) = 0;
            DataMapO(j) = Data.map(Refs4Display(i)).values(Profils.idxallpr(j,2),Profils.idxallpr(j,1));
        else
            DataMapN(j) = 0;
            DataMapO(j) = 0;
        end
    end
    LePro = find(LesRefsCarte == Refs4Display(i)); % warning, empty cell if missmatch.
    DataPr = Profils.data(:,LePro);
    
    figure, 
    subplot(2,1,1), plot(DataMapN,'+--r'), hold on, plot(DataMapO,'+-b')
    legend('Corrected','Old')
    subplot(2,1,2), plot(DataPr,'o-k')
    title(strcat('Element: ',Names4Display(i)))
    
end

Resp = questdlg('Do you want to keep new coordonates?','Action','yes','no','no');
if length(Resp) > 2
    Profils.idxallpr = IdxNewPr;
end

handles.profils = Profils;

guidata(hObject,handles);
return


% #########################################################################
%     DISPLAY SPECTRUM PROF/QUANTI (V2.1.1)  
function PRButton5_Callback(hObject, eventdata, handles)
Data = handles.data;
Profils = handles.profils;

for i=1:length(Profils.elemorder)
    ListElem(i) = Profils.elemorder(i);
end

Selected = get(handles.PPMenu1,'Value');
ListMap = get(handles.PPMenu1,'String');
NameMap = ListMap(Selected);

Map = Data.map(Selected).values;
RefElem = Data.map(Selected).ref; % Element for profile selection
NameSel = Data.map(Selected).name;


OKmaps = ismember(NameSel,ListElem);
WhereBad = find(OKmaps == 0);

if length(WhereBad)
    Str = NameSel{WhereBad(1)};
    
    CodeTxt = [8,10];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),char(Str)]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end


Position = find(ismember(ListElem,NameSel)); % On travail maintenant su le nom (Dec/10)

if length(Position) < 1 % Alors on est avec une carte corrigée et il va falloir aller chercher la référence
    NameSel = handles.NameMaps.elements(RefElem);
    Position = find(ismember(ListElem,NameSel));
end

% update 2.1.1
DataMapSelected = Data.map(Selected).values;

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    DataMapSelected = DataMapSelected.*handles.corrections(1).mask;
end

IdxAllPr = Profils.idxallpr;

for i=1:length(IdxAllPr(:,1))
    ValPro(i) = Profils.data(i,Position);
    ValMap(i) = DataMapSelected(IdxAllPr(i,2),IdxAllPr(i,1));
end

Correlation = corrcoef(ValPro.*Profils.pointselected',ValMap.*Profils.pointselected');  % edited 1.6.2

ValRapportL = [];

% On cherche a appliquer des barres pour comparer les positions
ComptL = 0;
ValMaxOx = max(ValPro) + 0.1*max(ValPro);
ValMaxMa = max(ValMap) + 0.1*max(ValMap);

XOx = [];
XMa = [];

for i=1:length(ValPro)-1 % On bosse sur les poids d'oxyde bien sur
    LesDeux = [ValPro(i),ValPro(i+1)];
    RapportL = max(LesDeux)/min(LesDeux);
    if RapportL > 1.4 && RapportL < 1000 % inf
        ComptL = ComptL+1;
        XOx(ComptL,:) = [i+0.5 i+0.5];
        YOx(ComptL,:) = [0 ValMaxOx];
        XMa(ComptL,:) = [i+0.5 i+0.5];
        YMa(ComptL,:) = [0 ValMaxMa];
        ValRapportL(ComptL) = RapportL;
    end
end         

NMaxL = 10;
if length(ValRapportL) > NMaxL
	[LesV,OuV] = sort(ValRapportL,'descend');
    XOx = XOx(OuV(1:NMaxL),:);
    YOx = YOx(OuV(1:NMaxL),:);
    XMa = XMa(OuV(1:NMaxL),:);
    YMa = YMa(OuV(1:NMaxL),:);
end

ValMinOx = min(ValPro) - 0.1*min(ValPro);
ValMinMa = min(ValMap) - 0.1*min(ValMap);
if ValMinOx < 0; ValMinOx = 0; end
if ValMinMa < 0; ValMinMa = 0; end

figure, 
subplot(2,1,1), hold on                                      % edited 1.6.2
for i=1:length(ValPro)
    % point
    if Profils.pointselected(i)
        plot(i,ValPro(i),'or','markersize',5,'MarkerFaceColor','r')
    else
        plot(i,ValPro(i),'ok','markersize',5,'MarkerFaceColor','k')
    end
    
    % line
    if i > 1
        if Profils.pointselected(i) && Profils.pointselected(i-1)
            plot([i-1,i],[ValPro(i-1),ValPro(i)],'-r')
        else
            plot([i-1,i],[ValPro(i-1),ValPro(i)],'-k')
        end
    end
end
%plot(ValPro,'*r-'), 
ylabel('Standard data (Wt%)'), 

for i=1:length(XOx)
    plot(XOx(i,:),YOx(i,:),'-k')
end
axis([1 length(ValPro) ValMinOx ValMaxOx])
set(gca,'xtick',[]); 
title(['Element: ',char(NameMap)])


subplot(2,1,2), hold on
for i=1:length(ValMap)
    % point
    if Profils.pointselected(i)
        plot(i,ValMap(i),'og','markersize',5,'MarkerFaceColor','g')
    else
        plot(i,ValMap(i),'ok','markersize',5,'MarkerFaceColor','k')
    end
    
    % line
    if i > 1
        if Profils.pointselected(i) && Profils.pointselected(i-1)
            plot([i-1,i],[ValMap(i-1),ValMap(i)],'-g')
        else
            plot([i-1,i],[ValMap(i-1),ValMap(i)],'-k')
        end
    end
end

%plot(ValMap,'*g-')
ylabel('Map data (counts)')

for i=1:length(XMa)
    plot(XMa(i,:),YMa(i,:),'-k')
end
axis([1 length(ValMap) ValMinMa ValMaxMa])
set(gca,'xtick',[]); 

if get(handles.CorrButtonBRC,'Value')
    title('BRC correction used - the filtered pixels values are zeros')
end

CodeTxt = [8,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(num2str(Correlation(1,2))),' (',char(NameSel),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(8).txt(9)),' ',char(num2str(Correlation(1,2))),' (',char(NameSel),')']);

disp(['Standards testing ... (Element: ',char(NameSel),') ...']);
disp(['Standards testing ... (Correlation: ',num2str(Correlation(1,2)),')']);
disp(['Standards testing ... (Element: ',char(NameSel),') .... Ok']);
disp(' ');

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
return


% #########################################################################
%     CHECK THE PROFILE/MAP POSITION (V2.1.1)
function PRButton7_Callback(hObject, eventdata, handles)
%

% [1] Calculate the correlation maps relative to the position of profils

disp('Check ... [Quality Check - Standard/Maps positions]')

% ---------- Data and select maps ----------
Data = handles.data;
for i=1:length(Data.map)
    ListMap(i) = Data.map(i).name;
    ListRefMap(i) = Data.map(i).ref;
end
%[SelectionMap] = listdlg('ListString',ListMap,'SelectionMode','multiple','Name','Select Maps');
SelectionMap = 1:i;
LesRefsCarte = ListRefMap(SelectionMap); 
LesNamesCartes = ListMap(SelectionMap);


% ---------- Standards spot analyses data ----------
Profils = handles.profils;
ProfilsElem = Profils.elemorder;
ListOri = handles.NameMaps.elements;
[Ok,LesRefsPro] = ismember(ProfilsElem,ListOri); % verification et creation de LesRefsPro

OKmaps = ismember(LesNamesCartes,ProfilsElem);
WhereBad = find(OKmaps == 0);

if length(WhereBad)
    Str = '';
    for i=1:length(WhereBad)
        Str=[Str,LesNamesCartes{WhereBad(i)},' - '];
    end
    Str(end-1:end) = '  ';
    
    CodeTxt = [8,10];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),char(Str)]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    disp(['The following maps have no corresponding elements in the standard data: ',char(Str)])
    disp('Check ... CANCELLED')
    disp(' ')
    return
end


% ---------- XShift & YShift ---------- 
Shift = inputdlg({'X-Shift      [(XY)ref system]','Y-Shift      [(XY)ref system]'},'Input',1,{'10','10'});
XShift = str2num(char(Shift{1}));
YShift = str2num(char(Shift{2}));

[TheCs,TheRs] = meshgrid(-XShift:1:XShift, -YShift:1:YShift);

Xok = Profils.idxallpr(:,1);


xref = Profils.idxallpr(:,1);
yref = Profils.idxallpr(:,2);

%[x,y] = CoordinatesFromRef(xref,yref,handles);
% The transformation above was uncorrect because we are working in the ref
% system (map is not from Fig's data).

x = xref;
y = yref;

Xmin = 1;
Xmax = size(Data.map(1).values,2);
Ymin = 1;
Ymax = size(Data.map(1).values,1);


for iSchift=1:length(TheCs(:))

    xTemp = x + TheCs(iSchift);
    yTemp = y + TheRs(iSchift);

    WhereOK = find(xTemp > Xmin & xTemp < Xmax & yTemp > Ymin & yTemp < Ymax);

    for i=1:length(SelectionMap)
        LaMap = find(ListRefMap == LesRefsCarte(i));
        LePro = find(LesRefsPro == LesRefsCarte(i)); 
        LesDataPro = Profils.data(:,LePro);
        
        if length(LaMap)  > 1
            warndlg('You have more than one map for an element !!!','Cancelled')
            return
        end
        
        FinalDataPro = LesDataPro(WhereOK);
        
        Coords = (xTemp-1)* Ymax + yTemp;
        FinalDataRaw = Data.map(LaMap).values(Coords(WhereOK));

        Correl = corrcoef(FinalDataRaw,FinalDataPro);
        CorrelationCoef(iSchift,i) = Correl(1,2);
    end

end

n=5;

if length(SelectionMap) <= 5
    m=1;
elseif length(SelectionMap) <=10
    m=2;
elseif length(SelectionMap) <=15
    m=3;
elseif length(SelectionMap) <=20
    m=4;
elseif length(SelectionMap) <=25
    m=5;
elseif length(SelectionMap) <=30
    m=6;
elseif length(SelectionMap) <=35
    m=7;
end


figure,
for i=1:length(SelectionMap)
    subplot(m,n,i)
    switch handles.rotateFig
        case 0
            imagesc(TheCs(1,:),TheRs(:,1),XimrotateX(reshape(CorrelationCoef(:,i),size(TheCs,1),size(TheCs,2)),0));  % format [X,Y,MAP]
        case 90
            imagesc(TheRs(:,1),TheCs(1,:),XimrotateX(reshape(CorrelationCoef(:,i),size(TheCs,1),size(TheCs,2)),90));  % format [X,Y,MAP]
        case 180
            imagesc(TheCs(1,:),TheRs(:,1),XimrotateX(reshape(CorrelationCoef(:,i),size(TheCs,1),size(TheCs,2)),180));  % format [X,Y,MAP]        case 270
        case 270
            imagesc(TheRs(:,1),TheCs(1,:),XimrotateX(reshape(CorrelationCoef(:,i),size(TheCs,1),size(TheCs,2)),270));  % format [X,Y,MAP]
    end
            
    %imagesc(reshape(CorrelationCoef(:,i),size(TheCs,1),size(TheCs,2)))
    axis image
    colorbar('horizontal');
    hold on, 
    plot(0,0,'*k');                       % original position
    hold off
    
    LaMap = find(ListRefMap == LesRefsCarte(i));
    title(Data.map(LaMap).name);
end


figure
switch handles.rotateFig
    case 0
        imagesc(TheCs(1,:),TheRs(:,1),XimrotateX(reshape(sum(CorrelationCoef.^2,2),size(TheCs,1),size(TheCs,2)),0));  % format [X,Y,MAP]
    case 90
        imagesc(TheRs(:,1),TheCs(1,:),XimrotateX(reshape(sum(CorrelationCoef.^2,2),size(TheCs,1),size(TheCs,2)),90));  % format [X,Y,MAP]
    case 180
        imagesc(TheCs(1,:),TheRs(:,1),XimrotateX(reshape(sum(CorrelationCoef.^2,2),size(TheCs,1),size(TheCs,2)),180));  % format [X,Y,MAP]        case 270
    case 270
        imagesc(TheRs(:,1),TheCs(1,:),XimrotateX(reshape(sum(CorrelationCoef.^2,2),size(TheCs,1),size(TheCs,2)),270));  % format [X,Y,MAP]
end
%imagesc(TheCs(1,:),TheRs(:,1),reshape(sum(CorrelationCoef.^2,2),size(TheCs,1),size(TheCs,2)))
axis image
colorbar('horizontal');
hold on, 
plot(0,0,'*k'); 

LaMap = find(ListRefMap == LesRefsCarte(i));
title('sum(corrcoef^2)');





disp('Check ... done');
disp(' ');



return


% #########################################################################
%     TRANSFERT TO QUANTI V2.1.1
function Tranfert2Quanti_Callback(hObject, eventdata, handles)
%

% THE BUTTON HAVE BEEN DELETED BUT THE FUNCTION IS STILL USED !!!
% P. Lanari (24.06.14)
%

Quanti = handles.quanti;

Data = handles.data; 
MaskFile = handles.MaskFile; 
MaskSelected = get(handles.PPMenu3,'Value');
Selected = get(handles.PPMenu1,'Value');

Mineral = get(handles.PPMenu2,'Value'); % 1 is none
MineralList = get(handles.PPMenu2,'String');
MineralName = MineralList(Mineral);

CodeTxt = [9,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

MethodQ = 'TTQuanti';
if Mineral == 1
    MineralName = 'X_ray_maps';
    LeMaskMin = ones(size(Data.map(1).values));
else
    LeMaskMin = zeros(size(MaskFile(MaskSelected).Mask));
    %keyboard
    LeMaskMin(find(MaskFile(MaskSelected).Mask == Mineral-1)) = ones(length(find(MaskFile(MaskSelected).Mask == Mineral-1)),1);
end

Name4write = inputdlg('Quanti name','define a name',1,{[char(MineralName),'-',char(MethodQ)]});

if length(Name4write) == 0
    CodeTxt = [9,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

% ---------- Where we are ---------- 
LaBonnePlace = length(Quanti)+1;

Quanti(LaBonnePlace).mineral = Name4write;
Quanti(LaBonnePlace).maskfile = 'not used';
Quanti(LaBonnePlace).nbpoints = 1; % for compatibility

% indexation Maps:
for i=1:length(Data.map)
    ListMap(i) = Data.map(i).name;
    ListRefMap(i) = Data.map(i).ref;
end

CodeTxt = [9,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);


AutoSelect = [1:1:length(ListMap)];
[SelectionMap] = listdlg('ListString',ListMap,'SelectionMode','multiple','Name','Select Maps','InitialValue',AutoSelect);

if SelectionMap
    LesRefsCarte = ListRefMap(SelectionMap); % Creation de LesRefsMap
    LesNamesCartes = ListMap(SelectionMap);
else
    CodeTxt = [9,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    return
end

% Border Removing Correction:
if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    BRCmask = handles.corrections(1).mask;
else
    BRCmask = ones(size(Data.map(1).values));
end

LesNomsOxydes = handles.NameMaps.oxydes(LesRefsCarte); % On indexe selon l'ordre des cartes


for i=1:length(LesRefsCarte)
    Quanti(LaBonnePlace).elem(i).ref = LesRefsCarte(i);
    Quanti(LaBonnePlace).elem(i).name = LesNomsOxydes{i};
    Quanti(LaBonnePlace).elem(i).values = 1;
    Quanti(LaBonnePlace).elem(i).coor = [1,1];
    Quanti(LaBonnePlace).elem(i).raw = 1;
    Quanti(LaBonnePlace).elem(i).param = [1,1];
    %if Mineral == 1
    %    Quanti(LaBonnePlace).elem(i).quanti = Data.map(i).values .* BRCmask;
    %else
    Quanti(LaBonnePlace).elem(i).quanti = Data.map(i).values .* LeMaskMin .* BRCmask;
    %end
end 
   
Quanti(LaBonnePlace).listname = LesNamesCartes; % On va garder les elements 
%Quanti(LaBonnePlace).listname = LesNomsOxydes;

% - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% EN DESSOUS LA FIN DE LA FONCTION QUANTI

handles.quanti = Quanti;

% ---------- Update Mineral Menu QUppmenu2 ---------- 
for i=1:length(Quanti)
    NamesQuanti(i) = Quanti(i).mineral;
end

set(handles.QUppmenu2,'String',NamesQuanti); 
set(handles.QUppmenu2,'Value',LaBonnePlace);
set(handles.QUtexte1,'String',strcat(num2str(Quanti(LaBonnePlace).nbpoints),' pts'));

% ---------- Update Wt% Menu QUppmenu1 ---------- 
set(handles.QUppmenu1,'String',Quanti(LaBonnePlace).listname);


% ---------- Display mode 2 ---------- 
%handles.currentdisplay = 2; % Input change
%set(handles.PPMenu2,'Value',1); % Input Change
%set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0); % median filter

ValMin = get(handles.QUppmenu2,'Value');
AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);
if char(SelMin) == char('.')
    warndlg('map not yet quantified','cancelation');
    return
end

% 
ValOxi = 1;
set(handles.QUppmenu1,'Value',ValOxi);

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(Quanti(ValMin).elem(ValOxi).quanti), axis image, colorbar('vertical')
set(handles.axes1,'xtick',[], 'ytick',[]); 
XMapColorbar(Quanti(ValMin).elem(ValOxi).quanti,handles,1)

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(Quanti(ValMin).elem(ValOxi).quanti(find(Quanti(ValMin).elem(ValOxi).quanti(:) ~= 0)),30)

AADonnees = Quanti(ValMin).elem(ValOxi).quanti(:);
Min = min(AADonnees(find(AADonnees(:) > 0)));
Max = max(AADonnees(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');
axes(handles.axes1);
if Max > Min
    caxis([Min,Max]);
end
% if Value == 1
% 	colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

disp(['Quantification processing ... (',char(MineralName),') ...']);
for i=1:length(LesNamesCartes)
    disp(['Quantification processing ... (',num2str(i),' - ',char(LesNamesCartes(i)),': ',num2str(Quanti(LaBonnePlace).elem(i).param(1)),'/',num2str(Quanti(LaBonnePlace).elem(i).param(2)),')']);
end
disp(['Quantification processing ... (',char(MineralName),') ... Ok']);
disp(' ');

CodeTxt = [9,6];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Name4write),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(6)),' (',char(Name4write),')']);

% set(handles.OPT,'Value',2); % on passe au panneau 2

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
AffOPT(2, hObject, eventdata, handles); % Maj 1.4.1
%AffPAN(hObject, eventdata, handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%     PRECISION MAP (V1.6.2)
function MButton4_Callback(hObject, eventdata, handles)

MaskFile = handles.MaskFile;
MaskSelected = get(handles.PPMenu3,'Value');

% Display
Selected = get(handles.PPMenu1,'Value');
Data = handles.data;

DispName = Data.map(Selected).name;

MineralSelected = get(handles.PPMenu2,'Value');
minName = get(handles.PPMenu2,'String');
    
if MineralSelected < 2
    MatrixData = Data.map(Selected).values;
    %minName = 'not selected';
else
    RefMin = MineralSelected - 1;
    PourCalcul = MaskFile(MaskSelected).Mask == RefMin;
    MatrixData = Data.map(Selected).values .* PourCalcul;
end    

% Initialisations
PrecMap = zeros(size(MatrixData));
[nLin,nCol] = size(MatrixData);

for i=1:length(MatrixData(:))
    if MatrixData(i)
        PrecMap(i) = 2./sqrt(MatrixData(i)).*100;            % edited 1.6.2
    else
        PrecMap(i) = 0;
    end
end

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    PrecMap = PrecMap.*handles.corrections(1).mask;
end

figure
imagesc(XimrotateX(reshape(PrecMap,nLin,nCol),handles.rotateFig)), axis image, colorbar, colormap([0,0,0;jet(64)])

caxis([min(PrecMap(find(PrecMap))), max(PrecMap(find(PrecMap)))])
title(['Precision (%, 2sigma) elem: ',char(DispName(1)),' & Min: ',char(minName(MineralSelected))]);

set(gca,'FontName','Times New Roman')
set(gca,'xtick',[], 'ytick',[]);
set(gca,'FontSize',10)

return
    

% #########################################################################
%     EDIT PROFILS - SELECT / UNSELECT POINTS (NEW V1.6.2)
function PRButton6_Callback(hObject, eventdata, handles)
%

% Activate the correction mode: 
handles.CorrectionMode = 1;
guidata(hObject,handles);

OnEstOu(hObject, eventdata, handles);


% first plot the current selected profils:
PRButton3_Callback(hObject, eventdata, handles);


CodeTxt = [7,12];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

clique = 1;
axes(handles.axes1); hold on
    
coordinates = handles.profils.idxallpr;                   % REF coordinates

while clique < 2
	[a,b,clique] = XginputX(1,handles);

    % -- Now we are working with the Ref coordinates (For projection)
    
    if clique < 2
        
        sumEcart = abs(coordinates(:,1)-a) + abs(coordinates(:,2)-b);
        selected = find(sumEcart == min(sumEcart));
                
        if handles.profils.pointselected(selected) == 1
            handles.profils.pointselected(selected) = 0;
        else
            handles.profils.pointselected(selected) = 1;
        end  
        
        guidata(hObject,handles);
        % first plot the current selected profils:
        PRButton3_Callback(hObject, eventdata, handles); 
        
        
    else
        break
    end
end


CodeTxt = [7,13];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    
GraphStyle(hObject, eventdata, handles)                % to hide the button
zoom on
guidata(hObject,handles);

% Activate the correction mode: 
handles.CorrectionMode = 0;
guidata(hObject,handles);

OnEstOu(hObject, eventdata, handles);

return


% #########################################################################
%     X-PAD -> UP (NEW V2.1.1)
function ButtonUp_Callback(hObject, eventdata, handles)
%
FunctionXPadDisplacement(hObject, eventdata, handles, 1);
return

% #########################################################################
%     X-PAD -> DOWN (NEW V2.1.1)
function ButtonDown_Callback(hObject, eventdata, handles)
%
FunctionXPadDisplacement(hObject, eventdata, handles, 2);
return

% #########################################################################
%     X-PAD -> RIGHT (NEW V2.1.1)
function ButtonRight_Callback(hObject, eventdata, handles)
%
FunctionXPadDisplacement(hObject, eventdata, handles, 3);
return

% #########################################################################
%     X-PAD -> LEFT (NEW V2.1.1)
function ButtonLeft_Callback(hObject, eventdata, handles)
%
FunctionXPadDisplacement(hObject, eventdata, handles, 4);
return


% #########################################################################
%     X-PAD APPLY BUTTON (NEW V2.1.1)
function ButtonXPadApply_Callback(hObject, eventdata, handles)
%

switch get(handles.ButtonXPadApply,'UserData')
    
    case 1   %  SPC
        
        % We have to check that the spot analyses are in the mapped area
        
        MapXMax = size(handles.data.map(1).values,2);   % rows
        MapYMax = size(handles.data.map(1).values,1);   % columns
        
        % We generate a new profils variable without the rejected points...
        
        Profils = handles.profils;
        
        ThoseOK = find(Profils.idxallpr(:,1) > 0 & Profils.idxallpr(:,1) < MapXMax+1 & Profils.idxallpr(:,2) > 0 & Profils.idxallpr(:,2) < MapYMax+1);
        
        if ~length(ThoseOK)
            return
        end
        
        NewProfils.elemorder = Profils.elemorder;
        NewProfils.display = Profils.display;
        NewProfils.xcoo = Profils.xcoo;
        NewProfils.ycoo = Profils.xcoo;
        
        
        NewProfils.coord = Profils.coord(ThoseOK,:);
        NewProfils.idxallpr = Profils.idxallpr(ThoseOK,:);
        NewProfils.data = Profils.data(ThoseOK,:);
        NewProfils.pointselected = Profils.pointselected(ThoseOK);
        NewProfils.idxallprORI = Profils.idxallprORI(ThoseOK,:);
        
        
        handles.profils = NewProfils;
        guidata(hObject, handles);
        
        % -> Cleaning
        PRButton4_Callback(hObject, eventdata, handles);

        % unactivate the mode
        set(handles.ButtonXPadApply,'UserData',0,'visible','off');

        disp(['SPC ... X correction of ',num2str(handles.profils.idxallpr(1,1)-handles.profils.idxallprORI(1,1)),' pixels applied ... OK']);
        disp(['SPC ... Y correction of ',num2str(handles.profils.idxallpr(1,2)-handles.profils.idxallprORI(1,2)),' pixels applied ... OK']);
        
        % -> Display the new coordonates Std analyses
        PRButton3_Callback(hObject, eventdata, handles);
        
        ValueDispCoord = get(handles.DisplayCoordinates,'Value');
        axes(handles.axes1)
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',1);
        end
        zoom on

        disp('SPC ... Done')
        disp(' ')
        
        CodeTxt = [15,14];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        set(handles.CorrPopUpMenu1,'value',1);
        
        
        guidata(hObject, handles);
        OnEstOu(hObject, eventdata, handles) 
        
        ValueDispCoord = get(handles.DisplayCoordinates,'UserData'); % here I used the UserData variable to remember the user choice before the correction mode...
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',1);
        end
        
        return
        
        
    case 2 % MPC
        
        % Changes where made, so just exit the mode...

        % unactivate the mode
        set(handles.ButtonXPadApply,'UserData',0,'visible','off');

        % Come back to VER_XMapTools_750 normal use: 
        ValueDispCoord = get(handles.DisplayCoordinates,'Value');
        axes(handles.axes1)
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',1);
        end
        
        zoom on
        
        disp('SPC ... Done')
        disp(' ')
        
        CodeTxt = [15,21];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        set(handles.CorrPopUpMenu1,'value',1);
        
        
        guidata(hObject, handles);
        OnEstOu(hObject, eventdata, handles)
        return
        
end

return


% #########################################################################
%     X-PAD GENERAL FUNCTION (NEW V2.1.1)
function FunctionXPadDisplacement(hObject, eventdata, handles, Dir)
%
% 1_Up - 2_Down - 3_Right - 4_Left

switch get(handles.ButtonXPadApply,'UserData')
    
    case 1   %  SPC
        
        % -> Cleaning
        PRButton4_Callback(hObject, eventdata, handles);
        
        % we plot the old profils...
        Profils = handles.profils;
        
        
        % Display the original positions...
        
        xrefORI = handles.profils.idxallprORI(:,1);
        yrefORI = handles.profils.idxallprORI(:,2);
        
        [xORI,yORI] = CoordinatesFromRef(xrefORI,yrefORI,handles);
        
        axes(handles.axes1)
        hold on
        for i=1:length(Profils.pointselected)
            if Profils.pointselected(i)
                plot(xORI(i),yORI(i),'+w')
                plot(xORI(i),yORI(i),'ow','markersize',4,'LineWidth',2)
            else
                plot(xORI(i),yORI(i),'+w')
                plot(xORI(i),yORI(i),'ow','markersize',4,'LineWidth',2)
            end
        end
        
        
        % Apply the correction
        
        xref = Profils.idxallpr(:,1);
        yref = Profils.idxallpr(:,2);
        
        [x,y] = CoordinatesFromRef(xref,yref,handles);
        
        switch Dir
            
            case 1 % Up
                NewX = x;
                NewY = y - 1;
               
            case 2 % Down
                NewX = x;
                NewY = y + 1;
                
            case 3 % Right
                NewX = x + 1;
                NewY = y;
                
            case 4 % Left
                NewX = x - 1;
                NewY = y;
                
        end
        
        [Newxref,Newyref] = CoordinatesFromFig(NewX,NewY,handles);
        
        handles.profils.idxallpr(:,1) = Newxref;
        handles.profils.idxallpr(:,2) = Newyref;
        guidata(hObject, handles);
        
        % -> Display the new coordonates Std analyses
        PRButton3_Callback(hObject, eventdata, handles);
        
        set(handles.PRButton6,'enable','off');
        
        
    case 2
        
        % 
        Selected = get(handles.PPMenu1,'Value');
        Shift = handles.data.map(Selected).shift;
        
        % Apply the correction
        
        switch Dir
            
            case 1 % Up
                Shift(1) = Shift(1) - 1;
               
            case 2 % Down
                Shift(1) = Shift(1) + 1;
                
            case 3 % Right
                Shift(2) = Shift(2) + 1;
                
            case 4 % Left
                Shift(2) = Shift(2) - 1;
                
        end
        
        [nL,nC] = size(handles.data.map(Selected).valuesORI);
        
        dL = Shift(1);
        dC = Shift(2);
        
        Dmat = zeros(nL+abs(dL),nC+abs(dC));
        
        Dmat(1+abs(dL)+dL:nL+abs(dL)+dL,1+abs(dC)+dC:nC+abs(dC)+dC) = handles.data.map(Selected).valuesORI;
        
        Tmat = Dmat(1+abs(dL):nL+abs(dL),1+abs(dC):nC+abs(dC));
        
        
        % Update the data
        handles.data.map(Selected).values = Tmat;
        handles.data.map(Selected).shift = Shift;
        
        guidata(hObject, handles);
        
        % Update display
        PPMenu1_Callback(hObject, eventdata, handles)
        
end



return


% #########################################################################
%     CORRECTION - RUN (NEW V2.1.1)
function CorrButton1_Callback(hObject, eventdata, handles)
% Run the corrections

LaQuelle = get(handles.CorrPopUpMenu1,'Value');

switch LaQuelle

% # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
    case 2     % BORDER REMOVE CORRECTION
       
        CorrTitle= 'BRC';
        
        MaskFile = handles.MaskFile;
        TheSel = get(handles.PPMenu3,'Value');
        
        % Set the correction scheme
        
        CodeTxt = [15,1];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (BCR)']); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        prompt={'X size of the window (X > 2 in px; odd number):','Q Reject criterion (Q in %)'};
        name='Input for BRC correction';
        numlines=1;
        defaultanswer={'3','100'};
        
        TheAnswers=inputdlg(prompt,name,numlines,defaultanswer);
        
        if ~length(TheAnswers)
            CodeTxt = [14,3];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            return
        end

        
        TheNbPx = str2num(TheAnswers{1});
        TheNbPxOnGarde = str2num(TheAnswers{2});
        
        % TEST for parity
        if ~mod(TheNbPx,2)
            CodeTxt = [15,19];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            return
        end
        

        % Proceed to the correction
        TheLin = size(MaskFile(TheSel).Mask,1);
        TheCol = size(MaskFile(TheSel).Mask,2);
        %CoordMatrice = reshape([1:TheLin*TheCol],TheLin,TheCol);
        
        TheMaskFinal = zeros(size(MaskFile(TheSel).Mask));
        
        Position = round(TheNbPx/2);
        TheNbPxInSel = TheNbPx^2;
        TheCriterion = TheNbPxInSel*TheNbPxOnGarde/100;
        
        for i=1:MaskFile(TheSel).Nb                % for each phase
            
            TheMask = zeros(size(MaskFile(TheSel).Mask));
            VectorOk = find(MaskFile(TheSel).Mask == i);
            
            TheMask(VectorOk) = ones(size(VectorOk));
            
            TheWorkingMat = zeros(size(TheMask,1)*size(TheMask,2),TheNbPxInSel+1);
            
            VectMask = TheMask(:);
            TheWorkingMat(find(VectMask)) = 1000*ones(size(find(VectMask)));
            
            Compt = 1;
            for iLin = 1:TheNbPx
                
                
                for iCol = 1:TheNbPx
                    
                    % SCAN
                    TheTempMat = zeros(size(TheMask));
                    TheTempMat(Position:end-(Position-1),Position:end-(Position-1)) = TheMask(iLin:end-(TheNbPx-iLin),iCol:end-(TheNbPx-iCol));
                    Compt = Compt+1;
                    TheWorkingMat(:,Compt) = TheTempMat(:);
            
                end
            end
            
            TheSum = sum(TheWorkingMat,2);
            OnVire1 = find(TheSum < 1000+TheCriterion & TheSum > 1000);
            TheMaskFinal(OnVire1) = ones(size(OnVire1));
            
        end
        
        TheMaskFinalInv = ones(size(TheMaskFinal));
        TheMaskFinalInv(find(TheMaskFinal(:) == 1)) = zeros(length(find(TheMaskFinal(:) == 1)),1);
        
        % Save the correction 1
        handles.corrections(1).value = 1;
        handles.corrections(1).mask = TheMaskFinalInv;
        
        %figure, imagesc(TheMaskFinalInv), axis image, colorbar
        
        set(handles.CorrButtonBRC,'Enable','on','Value',1);
        CorrButtonBRC_Callback(hObject, eventdata, handles)
        
        
        
% # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          
    case 3    % TOPO-RELATING CORRECTION
        
        CorrTitle = 'TRC';
        
        Data = handles.data.map;
        
        % BRC correction
        if get(handles.CorrButtonBRC,'Value') == 1
            for i=1:length(Data)
                
                % save first the value before replacing them
                WhereWeSave = find(handles.corrections(1).mask == 0);
                SavePxValues(i).values = zeros(size(handles.corrections(1).mask));
                SavePxValues(i).values(WhereWeSave) = Data(i).values(WhereWeSave);Data(i).values(WhereWeSave);
                
                % replace the values by zeros !
                Data(i).values = Data(i).values .*handles.corrections(1).mask;
            end
        end

        TheSelMask = get(handles.PPMenu3,'Value');
        MaskFile = handles.MaskFile(TheSelMask);
        
        ValueDispCoord = get(handles.DisplayCoordinates,'Value');
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',0);
        end
        zoom off
        
        [CorrMatrix,OrdoMatrix,OK] = XMTModTRC(Data,MaskFile);
        
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',1);
        end
        
        % ## Apply the correction to X-ray maps ##
        
        if OK == 1
        
            ListName = '';
            for i=1:length(Data)
                ListName{i} = char(Data(i).name);
            end

            WhereIsTopo = find(ismember(ListName,'TOPO'));

            
            disp('TRC ... [Topo-Related Correction]')

            for iMask=2:size(CorrMatrix,2) % Masks          % here from 2 ! This means that we don't apply the correction to the entire map...

                TheMask = zeros(size(MaskFile.Mask));
                VectorOk = find(MaskFile.Mask == iMask-1);
                TheMask(VectorOk) = ones(size(VectorOk));

                for iElem = 1:size(CorrMatrix,1); % Elements

                    if CorrMatrix(iElem,iMask) ~= 0
                        Xray = Data(iElem).values .* TheMask;
                        Topo = Data(WhereIsTopo).values .* TheMask;

                        %Ycorr = Yall - CorrMatrix(iElem,iMask)*Xall;

                        OldData = Data(iElem).values;
                        NewXray = Xray - CorrMatrix(iElem,iMask)*Topo;

                        Data(iElem).values(find(Xray)) = NewXray(find(Xray));

                        % Here isf you want to display the correction you
                        % should use: 
                        % figure, imagesc(Data(iElem).values-OldData), axis image, colorbar

                        disp(['TRC ... (correction of ',num2str(CorrMatrix(iElem,iMask)),' applied to: ',char(ListName{iElem}),' for ',char(MaskFile.NameMinerals{iMask}),') ... Ok']);

                    end
                end

            end
            
            % BRC correction
            if get(handles.CorrButtonBRC,'Value') == 1
                for i=1:length(Data)

                    % Add the original values of BRC rims to the corrected
                    % maps and display a warning !!!
                    
                    Data(i).values = Data(i).values + SavePxValues(i).values;
                end
            end
            

            handles.data.map = Data;
            handles.corrections(2).value = 1;
            
            guidata(hObject, handles);
            PPMenu1_Callback(hObject, eventdata, handles)
            disp('TRC ... Done')
            disp(' ')
            if get(handles.CorrButtonBRC,'Value') == 1
                disp('     WARNING: BRC was active the filtered pixels have not been corrected ...');
                disp(' ')
            end
        end
        
        
        
% # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          
	case 4    % Map Position Correction        
        
        disp('MPC ... [Map Position Correction]')
        
        
        ValueDispCoord = get(handles.DisplayCoordinates,'Value');
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',0);
            set(handles.DisplayCoordinates,'UserData',1);
        end
        
        zoom reset
        zoom out
        
        ButtonName = questdlg({'Would you like to calculate correlation maps','for different spot analyses positions'}, 'SPC', 'Yes');
        
        switch ButtonName

            case 'Yes'
                PRButton7_Callback(hObject, eventdata, handles);
                
            case 'No'
                % nothing happend here ...

            case 'Cancel'
                set(handles.CorrPopUpMenu1,'value',1)

                guidata(hObject, handles);
                OnEstOu(hObject, eventdata, handles) 
                return
                
        end
        
        % -> Define the shift variable
        Selected = get(handles.PPMenu1,'Value');
        
        % Here if a correction was done before, this correction and the
        % oridata are saved...
        if ~isfield(handles.data.map(Selected),'shift')
            handles.data.map(Selected).shift = [0,0];
        end
        if ~isfield(handles.data.map(Selected),'valuesORI')
            handles.data.map(Selected).valuesORI = handles.data.map(Selected).values;
        end
        
        if length(handles.data.map(Selected).shift) < 2  % WARNING 
            % Here this means that we used the correction for an other
            % map...
            handles.data.map(Selected).shift = [0,0];
            handles.data.map(Selected).valuesORI = handles.data.map(Selected).values;
        end
        
        % Activate the Correction Mode
        set(handles.ButtonXPadApply,'UserData',2,'Visible','on');                 % mode 1
        
        CodeTxt = [15,20];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        drawnow
        guidata(hObject, handles);
        OnEstOu(hObject, eventdata, handles);  % All button will be hidden...
        %set(handles.CorrButton1,'enable','off');
        set(handles.PRButton6,'enable','off');
        guidata(hObject, handles);
        return
        
        % The end of this function is in the APPLY button !!!!
        % We have to activate a editing mode in which all the buttons are
        % unable. 
        
        
% # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          
	case 5    % Coordinates of Standards spot analyses
        
        % first display the spot analyses 
        % -> Cleaning
        %PRButton4_Callback(hObject, eventdata, handles);
        
        % -> I used the function that work to display
        %PRButton3_Callback(hObject, eventdata, handles);
        
        disp('SPC ... [Standard Position Correction]')
        
        ValueDispCoord = get(handles.DisplayCoordinates,'Value');
        if ValueDispCoord
            set(handles.DisplayCoordinates,'Value',0);
            set(handles.DisplayCoordinates,'UserData',1);
        end
        %zoom off
        
        
        ButtonName = questdlg({'Would you like to calculate correlation maps','for different spot analyses positions'}, 'SPC', 'Yes');
        
        switch ButtonName

            case 'Yes'
                PRButton7_Callback(hObject, eventdata, handles);
                
            case 'No'
                % nothing happend here ...

            case 'Cancel'
                set(handles.CorrPopUpMenu1,'value',1)

                guidata(hObject, handles);
                OnEstOu(hObject, eventdata, handles) 
                return
                
        end
        
        
        % -> Display first the profils
        PRButton3_Callback(hObject, eventdata, handles);
        
        % -> Save the original positions... (last saved)
        handles.profils.idxallprORI = handles.profils.idxallpr;
        
        % Activate the Correction Mode
        set(handles.ButtonXPadApply,'UserData',1,'Visible','on');                 % mode 1
        
        
        CodeTxt = [15,13];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        drawnow
        guidata(hObject, handles);
        OnEstOu(hObject, eventdata, handles);  % All button will be hidden...
        %set(handles.CorrButton1,'enable','off');
        set(handles.PRButton6,'enable','off');
        guidata(hObject, handles);
        return
        
        % The end of this function is in the APPLY button !!!!
        % We have to activate a editing mode in which all the buttons are
        % unable. 
      
        
        
% # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
    case 6     % INTENSITY DRIFT CORRECTION
        
        axes(handles.axes1)
        zoom off
        
        CodeTxt = [13,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        % < - - - (1) User defines the direction
        DirChoice = questdlg('Select the direction','IDC','horizontal','vertical','vertical');
        
        switch DirChoice
            case 'horizontal'
                Direction = 2;
            case 'vertical'
                Direction = 1;
            case ''
                return
        end
        
        % < - - - (2) Define plot and extract the rectangle
        [FinalData,Coords] = SelectRectangleIntegration(hObject, eventdata, handles);
        
        CodeTxt = [13,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        TheMean = zeros(1,size(FinalData,1));
        Nb = zeros(1,size(FinalData,1));
        for i=1:size(FinalData,1)
            TheMean(i) = mean(FinalData(i,find(FinalData(i,:)>1e-19)));
            Nb(i) = length(find(FinalData(i,:)>1e-19));
        end
        
        if Direction == 2
            TheCoor = Coords(:,1);
        else
            TheCoor = Coords(:,2);
        end
        
        
        % < - - - (3) Define the correction
        figure, plot(TheCoor,TheMean,'ok'), hold on
        title('Select points for interpolation (right click to exit)');
        
        CodeTxt = [15,18];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        clique = 1; ComptPts = 1;
        while clique < 2
            [SelPixel(1),SelPixel(2),clique] = ginput(1); % On selectionne le pixel
            if clique < 2
                InterpolPixels(ComptPts,:) = round(SelPixel);
                plot(InterpolPixels(:,1),InterpolPixels(:,2), '-+r','linewidth', 2)
                ComptPts = ComptPts+1;  
            else
                break
            end
        end

        CodeTxt = [13,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        X = InterpolPixels(:,1); Y = InterpolPixels(:,2);
        
        if Direction == 2
            IntX = 1:1:length(handles.data.map(1).values(1,:));
        else
            IntX = 1:1:length(handles.data.map(1).values(:,1));
        end
        
        IntY = interp1(X,Y,IntX,'spline');
        figure, plot(TheCoor,TheMean,'ok'), hold on, plot(IntX,IntY,'-r','linewidth',2);
        title('Interpolated deviation');

        MaxInt = max(IntY);
        PivotPoint = find(IntY==MaxInt);
        plot([IntX(1),IntX(end)],[MaxInt,MaxInt],'-b')
        plot([PivotPoint],[MaxInt],'ob')
        
        
        % < - - - (5) Which X-ray map ???
        TheXMapSel = get(handles.PPMenu1,'Value');
        TheXMapData = handles.data.map(TheXMapSel).values;
        
        % Recuperer les data
        axes(handles.axes1)
        lesInd = get(handles.axes1,'child');

        % On extrait l'image...
        for i=1:length(lesInd)
            leType = get(lesInd(i),'Type');
            if length(leType) == 5
                if leType == 'image';
                    DataDisp = get(lesInd(i),'CData');
                end
            end   
        end
        
        
        % < - - - (4) Apply the correction
        
        Corr = 1+(1-(IntY/MaxInt));
        
        
        if Direction == 2
            CorrMatrix = repmat(Corr,size(TheXMapData,1),1);
        else
            CorrMatrix = repmat(Corr',1,size(TheXMapData,2));
        end
        
        
        figure, 
        subplot(2,2,1)
        imagesc(CorrMatrix), axis image, colorbar
        title('correction matrix');
        
        subplot(2,2,2)
        imagesc(TheXMapData.*(CorrMatrix-1)), axis image, colorbar
        title('Intensity Correction');
        
        subplot(2,2,3)
        imagesc(DataDisp.*CorrMatrix), axis image, colorbar, caxis([min(IntY),max(IntY)+50])
        title('Corrected Map');
        
        subplot(2,2,4)
        imagesc((TheXMapData-(TheXMapData.*(CorrMatrix)))./TheXMapData), axis image, colorbar
        title('Residuum Map'); 
        
        ButtonName = questdlg({'Would you like to apply the corrections to the map','This is an irreversible process'}, 'IDC', 'Yes');

        switch ButtonName

            case 'Yes'                
                DataUncorr = XimrotateX(TheXMapData,handles.rotateFig);
                DataCorr = DataUncorr.*CorrMatrix;
                DataCorrOk = XimrotateX(DataCorr,-handles.rotateFig);
                
                handles.data.map(TheXMapSel).values = DataCorrOk;
                guidata(hObject, handles);
                PPMenu1_Callback(hObject, eventdata, handles);
            case 'No'


            case 'Cancel'
                set(handles.CorrPopUpMenu1,'value',1);
                
                CodeTxt = [15,17];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

                return
        end
        
        CorrTitle = 'IDC';
        
        
end

CodeTxt = [15,2];
set(handles.TxtControl,'String',[char(CorrTitle),' ',char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

set(handles.CorrPopUpMenu1,'value',1)

guidata(hObject, handles);
OnEstOu(hObject, eventdata, handles) 
return


function chi2 = chiEvalXMap(P,X,Y,sigmaX,sigmaY,TheInternalFunction)
%
%   chi = chiEval(P,X,Y,sigmaX,sigmaY)
%   Objective function for chi^2 minimisation in chiFit.m
%	As in polyval, <<P is a vector of length N+1 whose elements are the coefficients of the polynomial in descending powers. >>
%
%	Benoit.Dubacq@upmc.fr - 20/09/2013


options = optimset('fminsearch'); 
options=optimset(options,'TolX',0.01,'TolFun',0.1, 'display','none','MaxFunEvals',1000,'MaxIter',1000, 'LargeScale','off');
bestXmodel = NaN * zeros(size(X));
for i = 1 : length(X)
    [bestXmodel(i),distMin] = fminsearch(TheInternalFunction,X(i),options,P,X(i),Y(i),sigmaX(i),sigmaY(i));
end

modelY = polyval(P,bestXmodel);

% chi2 = sum(((Y-modelY)./sigmaY).^2);
chi2 = sum((sqrt(((Y - modelY)./sigmaY).^2 + ((X - bestXmodel)./sigmaX).^2 )).^2); 

return


function dist = chiDistXMap(Xmodel,P,Xdata,Ydata,sigmaXdata,sigmaYdata)
%
%   dist = chiDist(P,X,Y,sigmaX,sigmaY);
%   Objective "distance" function for chi^2 minimisation in chiFit.m and chiEval.m
%   This function calculate the distance of the model to the data point in sigma units
%	As in polyval, <<P is a vector of length N+1 whose elements are the coefficients of the polynomial in descending powers. >>
%
%	Benoit.Dubacq@upmc.fr - 20/09/2013

Ymodel =  polyval(P,Xmodel);

dist = sqrt(((Ymodel - Ydata)/sigmaYdata)^2 + ((Xmodel - Xdata)/sigmaXdata)^2 ); % Note that distance is always positive

return



% #########################################################################
%     CORRECTION - SELECTION MENU (NEW V2.1.1)
function CorrPopUpMenu1_Callback(hObject, eventdata, handles)
%  

switch get(handles.CorrPopUpMenu1,'Value')
    case 1
        set(handles.CorrButton1,'String','CORRECT','Enable','off');
        
        CodeTxt = [13,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    case 2  % BRC
    	% We need to have a maskfile...
        if handles.MaskFile(1).type == 0
            set(handles.CorrButton1,'String','APPLY','Enable','off');
            
            CodeTxt = [15,4];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        else
            set(handles.CorrButton1,'String','APPLY','Enable','on');
            
            CodeTxt = [15,3];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        end
        
    case 3 % TRC
        if sum(ismember(get(handles.PPMenu1,'String'),'TOPO')) && ~handles.MaskFile(1).type == 0
            set(handles.CorrButton1,'String','SET','Enable','on');
            
            CodeTxt = [15,5];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        else
            set(handles.CorrButton1,'String','SET','Enable','off');
            
            CodeTxt = [15,6];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        end
                
    case 4
        
        if length(get(handles.PPMenu1,'String')) >= 2 && get(handles.PPMenu2,'Value') == 1
            set(handles.CorrButton1,'String','ACTIVATE','Enable','on');
            
            CodeTxt = [15,7];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        else
            set(handles.CorrButton1,'String','ACTIVATE','Enable','off');
            
            if get(handles.PPMenu2,'Value') > 1
                CodeTxt = [15,8];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            else
                CodeTxt = [15,9];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            end
            
            
            
        end
        
    case 5
        if length(handles.profils) < 1
            set(handles.CorrButton1,'String','ACTIVATE','Enable','off');
            
            CodeTxt = [15,12];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        else
            set(handles.CorrButton1,'String','ACTIVATE','Enable','on');
            
            CodeTxt = [15,10];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        end
        
    case 6 % IDC (Intensity Drift Correction)
        if get(handles.PPMenu2,'Value') > 1
            set(handles.CorrButton1,'String','APPLY','Enable','on');
            
            CodeTxt = [15,15];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        else
            set(handles.CorrButton1,'String','APPLY','Enable','off');
            
            CodeTxt = [15,16];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
        end
end

%OnEstOu(hObject, eventdata, handles)
return


% #########################################################################
%     CORRECTION - BRC (NEW V2.1.1)
function CorrButtonBRC_Callback(hObject, eventdata, handles)
%
axes(handles.axes1)
hcv = colormap;

if size(hcv,1) > 30
    PPMenu1_Callback(hObject, eventdata, handles)
else
    MaskButton2_Callback(hObject, eventdata, handles)
end



    

return




% -------------------------------------------------------------------------
% 5) QUANTI FUNCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%       PROCESS TO STANDARIZATION V1.6.4
function QUButton1_Callback(hObject, eventdata, handles)
%

% Methods (V1.4.1)
ModeQuanti = get(handles.QUmethod,'Value');

if ModeQuanti == 4
    Tranfert2Quanti_Callback(hObject, eventdata, handles);
    return
end

Quanti = handles.quanti;
Data = handles.data;
Profils = handles.profils;
Mask = handles.MaskFile;

% ---------- Setting ---------- 
MaskList = get(handles.PPMenu3,'String');
MaskSelected = get(handles.PPMenu3,'Value');
MaskFile = MaskList(MaskSelected);

Mineral = get(handles.PPMenu2,'Value'); % 1 is none
MineralList = get(handles.PPMenu2,'String');
MineralName = MineralList(Mineral);

MaskValues = Mask(MaskSelected).Mask == (Mineral-1); % first is none

if get(handles.CorrButtonBRC,'Value')
    % there is a BRC correction available
    MaskValues = MaskValues.*handles.corrections(1).mask;
end


% ---------- Check if there is matches between spot analyses and maps ----------
%            New 1.6.4
Compt = 0;
for i=1:length(Profils.idxallpr(:,1))
    if Profils.pointselected(i) && MaskValues(Profils.idxallpr(i,2),Profils.idxallpr(i,1))
        Compt = Compt+1;
    end
end

if Compt == 0
    % no matches
    if ModeQuanti == 1 || ModeQuanti == 2
        CodeTxt = [9,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        return
    end
end

% ---------- Where we are ---------- 
LaBonnePlace = length(Quanti)+1;

% Name (new V1.4.1)
CodeTxt = [9,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

if ModeQuanti == 1
    MethodQ = 'auto';
elseif ModeQuanti == 2
    MethodQ = 'manual';
else
    MethodQ = 'homog';
end

if get(handles.CorrButtonBRC,'Value')
    Name4write = inputdlg('Quanti name','define a name',1,{[char(MineralName),'-',char(MethodQ),'-BRC']});
else
    Name4write = inputdlg('Quanti name','define a name',1,{[char(MineralName),'-',char(MethodQ)]});
end

if length(Name4write) == 0
    CodeTxt = [9,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    return
end


Quanti(LaBonnePlace).mineral = Name4write;
Quanti(LaBonnePlace).maskfile = MaskFile;


% ---------- Setting ----------
% indexation Profils:
ProfilsElem = Profils.elemorder;
ListOri = handles.NameMaps.elements;
[Ok,LesRefsPro] = ismember(ProfilsElem,ListOri); % verification et creation de LesRefsPro

% indexation Maps:
for i=1:length(Data.map)
    ListMap(i) = Data.map(i).name;
    ListRefMap(i) = Data.map(i).ref;
end

CodeTxt = [9,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(1))]);

AutoSelect = [1:1:length(ListMap)];
[SelectionMap] = listdlg('ListString',ListMap,'SelectionMode','multiple','Name','Select Maps','InitialValue',AutoSelect);

if SelectionMap
    LesRefsCarte = ListRefMap(SelectionMap); % Creation de LesRefsMap
    LesNamesCartes = ListMap(SelectionMap);
else
    CodeTxt = [9,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(2))]);
    return
end

for i=1:length(Data.map) % On test pour toutes les cartes
    a = find(LesRefsCarte-i);
    if length(a) < length(LesRefsCarte)-1;
        CodeTxt = [9,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(3))]);
        return
    end
end

% La c'est completement tordu mais ca marche bien...
% en fait je joue sur la taille de la reponse de la fonction find.
LesNomsOxydes = handles.NameMaps.oxydes(LesRefsCarte); % On indexe selon l'ordre des cartes

% Si c'est un manuel homogene, il faut des entrees
if ModeQuanti == 3
    for i=1:length(LesNomsOxydes)
        DefautAnsw{i} = '0';
    end
    ValuesSTRQuanti = inputdlg(LesNomsOxydes,'Quanti values',1,DefautAnsw);
    
    if length(ValuesSTRQuanti) == 0
        CodeTxt = [9,2];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(2))]);
        return
    end
    % traitement    
    for i=1:length(ValuesSTRQuanti)
        ValuesQuanti(i) = str2num(ValuesSTRQuanti{i});
    end
end
 

% ---------- Quantification ---------- 
% On va partir des cartes et quantifier avec les profils correspondants
% l'inverse semble non solide. 
% C'est a dire que le choix des carte est judicieux...

for i=1:length(LesRefsCarte)
    LaMap = LesRefsCarte(i);
    LePro = find(LesRefsPro == LaMap); % warning, empty cell if missmatch.
    
    if ~length(LePro)
        CodeTxt = [9,12];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),char(handles.data.map(i).name)]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        return
    end
    
    Quanti(LaBonnePlace).elem(i).ref = LaMap; 
    
    Quanti(LaBonnePlace).elem(i).name = LesNomsOxydes(i); % yet sort
    
    Quanti(LaBonnePlace).elem(i).values = Profils.data(:,LePro);
    Quanti(LaBonnePlace).elem(i).coor = Profils.idxallpr;
    
    for j=1:length(Quanti(LaBonnePlace).elem(i).coor)
        Line = Quanti(LaBonnePlace).elem(i).coor(j,2); % Y -> L
        Column = Quanti(LaBonnePlace).elem(i).coor(j,1); % X -> C
        if Line && Column
            Quanti(LaBonnePlace).elem(i).raw(j) = MaskValues(Line,Column) * Data.map(SelectionMap(i)).values(Line,Column);
            Quanti(LaBonnePlace).elem(i).values(j) = MaskValues(Line,Column) * Quanti(LaBonnePlace).elem(i).values(j);
        else
            Quanti(LaBonnePlace).elem(i).raw(j) = 0;
            Quanti(LaBonnePlace).elem(i).values(j) = 0;
        end
    end
    
    
    
    Ox=[]; Ra=[];
    Compt = 1;
    for j=1:length(Quanti(LaBonnePlace).elem(i).values)
        if Quanti(LaBonnePlace).elem(i).values(j) > 0  && Profils.pointselected(j)    % Edited 1.6.2 (compatible with select/uselect points)
            Ox(Compt) = Quanti(LaBonnePlace).elem(i).values(j);
            Ra(Compt) = Quanti(LaBonnePlace).elem(i).raw(j);
            Compt = Compt+1;
        else
            Quanti(LaBonnePlace).elem(i).values(j) = 0;    % Edited 1.6.2 (compatible with select/uselect points)
            Quanti(LaBonnePlace).elem(i).raw(j) = 0;       % we fixed to zero the unused compositions (for the plots).
            
            % bug correction (1.6.4) resulting from 0 intensity values
            %                        --> no matches between minerals and profils warning
            %
            %                            But now, the softawre doesn't detect
            %                            mask without quantitative
            %                            analyses...
            Ox(Compt) = 0.0000001;
            Ra(Compt) = 1.; 
        end
    end    
    
    if ModeQuanti == 3
       % Manual (homogeneous phase) new 1.4.1
       % ici on a pas besoin de vérifier si il y a des correspondances...
       LesDataZero = Data.map(SelectionMap(i)).values.*MaskValues;
       LesData = LesDataZero(find(LesDataZero));
       Intensity = [ValuesQuanti(i),median(LesData)];
       Quanti(LaBonnePlace).elem(i).param = Intensity;
       Quanti(LaBonnePlace).elem(i).quanti = (Data.map(SelectionMap(i)).values.*MaskValues) ./ (Intensity(2)/Intensity(1));
         
    end
    if ModeQuanti == 2
        % Manual (New V1.4.1)
        if Ox
            figure(1), hold off
            plot(Ox,Ra,'+k')
            title(char(Quanti(LaBonnePlace).elem(i).name))
            Intensity = ginput(1);
            Quanti(LaBonnePlace).elem(i).param = Intensity;
            Quanti(LaBonnePlace).elem(i).quanti = (Data.map(SelectionMap(i)).values.*MaskValues) ./ (Intensity(2)/Intensity(1));
            
        else
            % Modification 1.6.4 
            % This part is no more used (this detection is done above). 
            CodeTxt = [9,4];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(4))]);
            return        
        end
        
    elseif ModeQuanti == 1
        % automatique
        if Ox
            Intensity = [median(Ox),median(Ra)];
            Quanti(LaBonnePlace).elem(i).param = Intensity;
            Quanti(LaBonnePlace).elem(i).quanti = (Data.map(SelectionMap(i)).values.*MaskValues) ./ (Intensity(2)/Intensity(1));    
        else
            % cette phase n'a pas de profils correspondant...
            CodeTxt = [9,4];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(4))]);
            return
        end
    end
    
end
    
% ---------- Save ---------- 
Quanti(LaBonnePlace).nbpoints = Compt-1; % for display
Quanti(LaBonnePlace).listname = LesNomsOxydes; % Selected maps
% Quanti(LaBonnePlace).listname{length(Quanti(LaBonnePlace).listname) + 1} = 'SUM';
handles.quanti = Quanti;

% ---------- Update Mineral Menu QUppmenu2 ---------- 
for i=1:length(Quanti)
    NamesQuanti{i} = char(Quanti(i).mineral);
end

set(handles.QUppmenu2,'String',NamesQuanti); 
set(handles.QUppmenu2,'Value',LaBonnePlace);
set(handles.QUtexte1,'String',strcat(num2str(Quanti(LaBonnePlace).nbpoints),' pts'));

% ---------- Update Wt% Menu QUppmenu1 ---------- 
set(handles.QUppmenu1,'String',Quanti(LaBonnePlace).listname);


% ---------- Display mode 2 ---------- 
%handles.currentdisplay = 2; % Input change
%set(handles.PPMenu2,'Value',1); % Input Change
%set(handles.REppmenu1,'Value',1); % Input Change

set(handles.FIGbutton1,'Value',0); % median filter

ValMin = get(handles.QUppmenu2,'Value');
AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);
if char(SelMin) == char('.')
    warndlg('map not yet quantified','cancelation');
    return
end

% 
ValOxi = 1;
set(handles.QUppmenu1,'Value',ValOxi);

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(XimrotateX(Quanti(ValMin).elem(ValOxi).quanti,handles.rotateFig)), axis image, colorbar('vertical')
XMapColorbar(Quanti(ValMin).elem(ValOxi).quanti,handles,1)
set(handles.axes1,'xtick',[], 'ytick',[]); 

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(Quanti(ValMin).elem(ValOxi).quanti(find(Quanti(ValMin).elem(ValOxi).quanti(:) ~= 0)),30)

AADonnees = Quanti(ValMin).elem(ValOxi).quanti(:);
Min = min(AADonnees(find(AADonnees(:) > 0)));
Max = max(AADonnees(:));

set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

Value = get(handles.checkbox1,'Value');
axes(handles.axes1);
if Max > Min
    caxis([Min,Max]);
end
% if Value == 1
% 	colormap([0,0,0;jet(64)])
% else
%     colormap([jet(64)])
% end

disp(['Standardization processing ... (',char(MineralName),') ...']);
for i=1:length(LesNamesCartes)
    disp(['Standardization processing ... (',num2str(i),' - ',char(LesNamesCartes(i)),': ',num2str(Quanti(LaBonnePlace).elem(i).param(1)),'/',num2str(Quanti(LaBonnePlace).elem(i).param(2)),')']);
end
disp(['Standardization processing ... (',char(MineralName),') ... Ok']);
disp(' ');

CodeTxt = [9,6];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Name4write),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(6)),' (',char(Name4write),')']);

% set(handles.OPT,'Value',2); % on passe au panneau 2

GraphStyle(hObject, eventdata, handles)
guidata(hObject,handles);
AffOPT(2, hObject, eventdata, handles); % Maj 1.4.1
%AffPAN(hObject, eventdata, handles);
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%       STANDARDIZATION METHOD LIST
function QUmethod_Callback(hObject, eventdata, handles)
OnEstOu(hObject, eventdata, handles);
return


% #########################################################################
%       PLOT It/Wt% V1.4.1
function QUbutton11_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

ValMin = get(handles.QUppmenu2,'Value');

for i=1:length(Quanti(ValMin).elem)
    % for each element
    Raw(:,i) = Quanti(ValMin).elem(i).raw;
    Val(:,i) = Quanti(ValMin).elem(i).values;
    Coor(:,i) = Quanti(ValMin).elem(i).param'; % Ox / Raw
    
    TheNames{i} = char(Quanti(ValMin).elem(i).name);
end

figure, 
plot(Val(:,1:length(Val(1,:))),Raw(:,1:length(Raw(1,:))),'+'), hold on
legend(TheNames,'location','SouthEast')
for i=1:length(Val(1,:))
    plot([0, Coor(1,i)],[0, Coor(2,i)])
end

AllMin = get(handles.QUppmenu2,'String');
SelMin = AllMin(ValMin);

xlabel('Weigth percent'), ylabel('Intensity'), 
title(['Quantification parameters for ',char(SelMin)]);

guidata(hObject,handles);
return


% #########################################################################
%       TEST THE STANDARDIZATION  V1.6.5
function QUbutton_TEST_Callback(hObject, eventdata, handles)

Quanti = handles.quanti;
ValMin = get(handles.QUppmenu2,'Value');

% Standard analyses of the selected Qmineral
lesQuels = find(Quanti(ValMin).elem(1).raw);

ComposFromStd = zeros(length(lesQuels),length(Quanti(ValMin).elem));
ComposFromMaps = zeros(length(lesQuels),length(Quanti(ValMin).elem));

MapUncertainties = zeros(length(lesQuels),length(Quanti(ValMin).elem));


for i = 1:length(Quanti(ValMin).elem)                            % elements
    for j = 1:length(lesQuels)                          % good std analyses
        
        ComposFromStd(j,i) = Quanti(ValMin).elem(i).values(lesQuels(j));
        % Ligne/Coll <-> X and Y
        ComposFromMaps(j,i) = Quanti(ValMin).elem(i).quanti(Quanti(ValMin).elem(1).coor(lesQuels(j),2),Quanti(ValMin).elem(1).coor(lesQuels(j),1));
        
        MapUncertainties(j,i) = 2/sqrt(Quanti(ValMin).elem(i).raw(lesQuels(j))); % in % at 2%
        
    end
        
    figure, plot(ComposFromStd(:,i),ComposFromMaps(:,i),'.')
    hold on
    for k=1:length(MapUncertainties(:,i))
        devMap = ComposFromMaps(k,i)*MapUncertainties(k,i);
        
        if median(ComposFromStd(:,i)) < 0.2
            devStd = ComposFromStd(k,i)* 0.1;   % 1%.
        elseif median(ComposFromStd(:,i)) < 1
            devStd = ComposFromStd(k,i)* 0.05;   % 1%.
        else
            devStd = ComposFromStd(k,i)* 0.01;   % 1%.
        end
        
        devStdSave(k) = devStd;
        devMapSave(k) = devMap;
        
        plot([ComposFromStd(k,i),ComposFromStd(k,i)],[ComposFromMaps(k,i) - devMap, ComposFromMaps(k,i) + devMap],'-')
        plot([ComposFromStd(k,i) - devStd, ComposFromStd(k,i) + devStd],[ComposFromMaps(k,i),ComposFromMaps(k,i)],'-')

    end
    plot([0 100],[0 100],'-k')

    hold off
    
    title(Quanti(ValMin).elem(i).name);
    xlabel('Standard composition (Wt%) - error (<0.2%=10% <1%=5% else 1%')
    ylabel('Corresponding pixel composition (Wt%) - error 2o')
    
    if median(ComposFromStd(:,i)) < 0.2
        axis([0,0.2,0,0.2])
    elseif median(ComposFromStd(:,i)) < 1 
        axis([0,1,0,1])
    elseif median(ComposFromStd(:,i)) < 5
        axis([0,5,0,5])
    elseif median(ComposFromStd(:,i)) < 10
        valueMean = mean(ComposFromStd(:,i));
        axis([round(valueMean-2),round(valueMean+2),round(valueMean-2),round(valueMean+2)])
    else
        valueMean = mean(ComposFromStd(:,i));
        axis([round(valueMean-5),round(valueMean+5),round(valueMean-5),round(valueMean+5)])
    end
     
    % ---------------------------------------------------------------------
    % UNCERTAINTIES: R2 and CHI2 
    X = ComposFromStd(:,i);
    Y = ComposFromMaps(:,i);
    
    SigmaX = devStdSave';
    SigmaY = devMapSave';
    
    for i=1:length(SigmaX)
        if ~SigmaX(i)
            SigmaX(i)=0.0001;
        end
    end
    
    P = [1,0];   % slope / intercept of the linear predictor
    
    options = optimset('fminsearch'); 
    options=optimset(options,'TolX',0.01,'TolFun',0.1, 'display','none','MaxFunEvals',1000,'MaxIter',1000, 'LargeScale','off');
 	bestXmodel = NaN * zeros(size(X));
    f = @chiDist;
    
    for i=1:length(X)
        [bestXmodel(i),distMin] = fminsearch(f,X(i),options,P,X(i),Y(i),SigmaX(i),SigmaY(i));
    end
    
    modelY = polyval(P,bestXmodel);
    
    chi2s = sum(((Y-modelY)./SigmaY).^2);
    chi2Ns = chi2s/length(X);
    
    % With X and Y uncertainties (P. Lanari, Septembre 2013 - equation B3 in Dubacq et al., 2013)
    chi2 = sum((sqrt(((Y - modelY)./SigmaY).^2 + ((X - bestXmodel)./SigmaX).^2 )).^2);
    chi2N = chi2/length(X);
        
    % MATLAB version
    R2 = 1 - sum((Y-modelY).^2)/((length(Y)-1)*var(Y));
    
    % BENOIT DUBACQ version
    meanData = sum(Y)/length(Y); meanModel = sum(modelY)/length(modelY);
    R2 = sum((Y-meanData).*(modelY-meanModel)) ./ sqrt(sum((Y-meanData).^2) .* sum((modelY-meanModel).^2));
    
    Xlim = get(gca,'Xlim'); Ylim = get(gca,'Ylim');
    text(Xlim(1)+(Xlim(2)-Xlim(1))/50,Ylim(2)-(Ylim(2)-Ylim(1))/30,['N=',num2str(length(Y)),'; R2=',num2str(R2),'; Chi2=',num2str(chi2N)])

    
end
    
return


% #########################################################################
%       CHI-DISTANCE FUNCTION   (NEW) V1.6.5
function dist = chiDist(Xmodel,P,Xdata,Ydata,sigmaXdata,sigmaYdata);
%
%   dist = chiDist(P,X,Y,sigmaX,sigmaY);
%   Objective "distance" function for chi^2 minimisation in chiFit.m and chiEval.m
%   This function calculate the distance of the model to the data point in sigma units
%	As in polyval, <<P is a vector of length N+1 whose elements are the coefficients of the polynomial in descending powers. >>
%
%	Benoit.Dubacq@upmc.fr - 20/09/2013

Ymodel =  polyval(P,Xmodel);

dist = sqrt(((Ymodel - Ydata)/sigmaYdata)^2 + ((Xmodel - Xdata)/sigmaXdata)^2 ); % Note that distance is always positive

return


% #########################################################################
%       DELETE A QUANTI (NEW 1.4.1)
function QUbutton0_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

Delete = get(handles.QUppmenu2,'Value'); % for "none"


if Delete == 2 % On enleve la première quanti
    NewQuanti(1) = Quanti(1); % La première change jamais
    for k = 2:length(Quanti) - 1
        NewQuanti(k) = Quanti(k+1);
    end
end
if Delete > 2 && Delete < length(Quanti)
    NewQuanti(1:Delete-1) = Quanti(1:Delete-1); 
    for k = Delete:length(Quanti)-1
        NewQuanti(k) = Quanti(k+1);
    end
end
if Delete == length(Quanti)
    NewQuanti(1:Delete-1) = Quanti(1:Delete-1); 
end


for i=1:length(NewQuanti)
    ListName{i} = char(NewQuanti(i).mineral);
end

set(handles.QUppmenu2,'String',ListName)
set(handles.QUppmenu2,'Value',2)

handles.quanti = NewQuanti;

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
QUppmenu2_Callback(hObject, eventdata, handles)


return


% #########################################################################
%       RENAME A QUANTI (NEW 1.4.1)
function QUbutton4_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

Selected = get(handles.QUppmenu2,'Value');
ListName = get(handles.QUppmenu2,'String');

Name = ListName(Selected);

CodeTxt = [9,10];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(10))]);
NewName = inputdlg({'New name'},'Rename QUANTI',1,Name);

if ~length(NewName)
    CodeTxt = [9,9];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(9))]);
    return
end

ListName(Selected) = NewName;
Quanti(Selected).mineral = NewName;
handles.quanti = Quanti;

set(handles.QUppmenu2,'String',ListName);

CodeTxt = [9,11];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(NewName),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(9).txt(11)),' (',char(NewName),')']);

guidata(hObject,handles);
return


% #########################################################################
%       MERGE QMINERALS (1.6.1)
function QUbutton5_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

% (1) Choix des cartes
for i=1:length(Quanti)-1
    ListMaps(i) = Quanti(i+1).mineral;
end

CodeTxt = [10,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(1))]);
Init = 1:length(ListMaps);
MapChoice = listdlg('ListString',ListMaps,'SelectionMode','multiple','Initialvalue',Init,'Name','Select quanti');

if ~length(MapChoice)
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
    return
end

% We change the coord (including 'none')
MapChoice = MapChoice+1;

% Verification... Number of element for each map
for i = 1:length(MapChoice)
    NbElemMap(i) = length(Quanti(MapChoice(i)).listname);
end

% Last option V 1.4.1 (01/06/11)
if sum(NbElemMap) ~= NbElemMap(1)*length(NbElemMap)
    % Error
    CodeTxt = [10,12];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(12))]);
    return
end

SizeMap = size(Quanti(MapChoice(1)).elem(1).quanti);

% On cree la carte MapQuanti pour chaque element
for i=1:length(Quanti(MapChoice(1)).elem)
    MapQuanti(i).elem(:,:) = zeros(SizeMap);
end


ListElem = Quanti(MapChoice(1)).listname;

if get(handles.MergeInterpBoundaries,'Value');
    CodeTxt = [10,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(2))]);
    
    if find(ismember(ListElem,'SiO2'))
        AutoSelect = find(ismember(ListElem,'SiO2'));
    else
        AutoSelect = 1;
    end
    LaMapRef = listdlg('ListString',ListElem,'SelectionMode','single','InitialValue',AutoSelect);
    if ~length(LaMapRef)
        CodeTxt = [10,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
        return
    end
end

% (2) Maps -> Map
for i=1:length(MapChoice) % par masque
    LaQuanti = Quanti(MapChoice(i));
    
    for j=1:length(LaQuanti.elem) % par element
        MapQuanti(j).elem = MapQuanti(j).elem + LaQuanti.elem(j).quanti;
    end
end




if get(handles.MergeInterpBoundaries,'Value'); % interpolation

    % (3) Verification et on refait les bordures en mélanges simples

    Nb = 2;
    PerKeep = 0.5;

    CodeTxt = [10,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(3))]);
    Answ = inputdlg({'X-n -> X+n','OnGarde'},'Interpolation',1,{num2str(Nb),num2str(PerKeep)});
    if ~length(Answ)
        CodeTxt = [10,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
        return
    end
    Nb = str2num(Answ{1});
    PerKeep = str2num(Answ{2});


    NewMapQuanti = MapQuanti;

    WaitBarPerso(0, hObject, eventdata, handles);
    
    ComptAffich = 20;
    for i=1:length(MapQuanti(LaMapRef).elem(:,1))
        if i == ComptAffich
            ComptAffich = ComptAffich + 20;
            WaitBarPerso(i/length(MapQuanti(LaMapRef).elem(:,1)), hObject, eventdata, handles);

            CodeTxt = [10,7];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(round((i/length(MapQuanti(LaMapRef).elem(:,1)))*100)),' %)']); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);


            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(7)),' (',num2str(round((i/length(MapQuanti(LaMapRef).elem(:,1)))*100)),' %)']);
            drawnow
        end

        for j=1:length(MapQuanti(LaMapRef).elem(1,:))
            if MapQuanti(LaMapRef).elem(i,j) == 0 % il faut géréer un trou
                % i lignes j colones
                if i <= Nb
                    Decali1 = i;
                    Decali2 = i+Nb;
                    Nbi1 = Nb; Nbi2 = 0;
                elseif i >= length(MapQuanti(1).elem(:,1)) - Nb
                    Decali1 = i-Nb;
                    Decali2 = i;
                    Nbi1 = Nb; Nbi2 = 0;
                else % on est au milieu pour i
                    Decali1 = i-Nb;
                    Decali2 = i+Nb;
                    Nbi1 = Nb; Nbi2 = Nb;
                end

                if j <= Nb
                    Decalj1 = j;
                    Decalj2 = j+Nb;
                    Nbj1 = Nb; Nbj2 = 0;
                elseif j >= length(MapQuanti(1).elem(1,:)) -5
                    Decalj1 = j-Nb;
                    Decalj2 = j;
                    Nbj1 = Nb; Nbj2 = 0;
                else
                    Decalj1 = j-Nb;
                    Decalj2 = j+Nb;
                    Nbj1 = Nb; Nbj2 = Nb;
                end

                % Enfin Correction
                clear LesVals
                LesVals = MapQuanti(LaMapRef).elem(Decali1:Decali2,Decalj1:Decalj2);
                NbOk = length(find(LesVals > 0));
                if NbOk/((Nbi1+Nbi2+1)*(Nbj1+Nbj2+1)) > PerKeep% 80% de definis
                    % On corrige bien
                    for k = 1:length(MapQuanti) % pour chaque element
                        LesVals = MapQuanti(k).elem(Decali1:Decali2,Decalj1:Decalj2);
                        LaMoyenne = mean(LesVals(find(LesVals > 0)));
                        NewMapQuanti(k).elem(i,j) = LaMoyenne;
                    end
                else
                        % On met des NaN pour tous les éléments
                    for k = 1:length(MapQuanti) % pour chaque element
                        NewMapQuanti(k).elem(i,j) = NaN;
                    end
                end 
            end
        end
    end 
    WaitBarPerso(1, hObject, eventdata, handles);  

else
    
    NewMapQuanti = MapQuanti;  % tout simplement
    
end


% Aller il faut sauvegarder maintenant...

CodeTxt = [10,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(5))]);

Name4Bulk =  'Merged_Map';
Name4Bulk = inputdlg({'Name'},'...',1,{Name4Bulk});
if ~length(Name4Bulk)
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
    return
end

QuantiBulk.mineral = Name4Bulk;

for i=1:length(ListElem)
    QuantiBulk.elem(i).ref = Quanti(MapChoice(1)).elem(i).ref;
    QuantiBulk.elem(i).name = ListElem{i};
    QuantiBulk.elem(i).values = [0,0];
    QuantiBulk.elem(i).coor = [0,0];
    QuantiBulk.elem(i).raw = [0,0];
    QuantiBulk.elem(i).param = [0,0];
    QuantiBulk.elem(i).quanti = NewMapQuanti(i).elem;
end

QuantiBulk.listname = ListElem;
QuantiBulk.maskfile = {'none BULK-Quanti'};
QuantiBulk.nbpoints = 0;


CombQuanti = length(Quanti)+1;
Quanti(CombQuanti) = QuantiBulk;


for i=1:length(Quanti)
    FListMaps(i) = Quanti(i).mineral;
end

set(handles.QUppmenu2,'String',FListMaps);
set(handles.QUppmenu2,'Value',CombQuanti);

% update
handles.quanti = Quanti;
guidata(hObject,handles);

CodeTxt = [10,6];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Name4Bulk),')']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(6)),' (',char(Name4Bulk),')']);
% display
QUppmenu2_Callback(hObject, eventdata, handles);
return


% #########################################################################
%       BULK MAP (1.6.4)
function QUbutton6_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;
LaQuelle = get(handles.QUppmenu2,'Value');

ListName = Quanti(LaQuelle).listname;


% Preparation to detect Pixels values of zero (MasqueFilter variable)     % New 1.6.4
TheSumMaps = zeros(size(Quanti(LaQuelle).elem(1).quanti,1),size(Quanti(LaQuelle).elem(1).quanti,2));
MasqueFilter = zeros(size(Quanti(LaQuelle).elem(1).quanti,1),size(Quanti(LaQuelle).elem(1).quanti,2));
for i=1:length(Quanti(LaQuelle).elem)
    TheSumMaps= TheSumMaps + Quanti(LaQuelle).elem(i).quanti;
end

MasqueFilter(find(TheSumMaps > 0)) = ones(length(find(TheSumMaps > 0)),1);    


for i=1:length(Quanti(LaQuelle).elem)
    LesVals = Quanti(LaQuelle).elem(i).quanti(:);
    LesVals = LesVals + 0.0000001;
    LesValsOk = LesVals .* MasqueFilter(:);
    LaMoy(i) = mean(LesValsOk(find(LesValsOk > 0))); % NaNs are rejected.
end

CodeTxt = [10,8];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(8))]);

[Success,Message,MessageID] = mkdir('Exported-LocalCompos');

cd Exported-LocalCompos
[Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export Bulk-compo as');
cd ..

if ~Directory
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
    return
end


fid = fopen(strcat(pathname,Directory),'w');
fprintf(fid,'%s\n\n','Local composition (Map) from XMapTools');
for i = 1:length(ListName)
    fprintf(fid,'%s\t',[char(ListName(i))]);
    fprintf(fid,'%s\n',[num2str(LaMoy(i))]);
end

fprintf(fid,'\n');

fprintf(fid,'%s\t',['SUM']);
fprintf(fid,'%s\n',[num2str(sum(LaMoy))]);

fclose(fid);

CodeTxt = [10,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(9))]);

return


% #########################################################################
%       BULK AREA (1.6.4)
function QUbutton7_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;
LaQuelle = get(handles.QUppmenu2,'Value');

ListName = Quanti(LaQuelle).listname;

% Selection of area
CodeTxt = [10,10];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(10))]);
clique = 1;
ComptResult = 1;
axes(handles.axes1); hold on

h = [0];

while clique < 2
	[a,b,clique] = XginputX(1,handles);
    if clique < 2
    	h(ComptResult,1) = a;
        h(ComptResult,2) = b;
        
        [aPlot,bPlot] = CoordinatesFromRef(a,b,handles);
        
        % new (1.6.2)
        hPlot(ComptResult,1) = aPlot;
        hPlot(ComptResult,2) = bPlot;
        
        plot(floor(hPlot(ComptResult,1)),floor(hPlot(ComptResult,2)),'.w') % point
        if ComptResult >= 2 % start
        	plot([floor(hPlot(ComptResult-1,1)),floor(hPlot(ComptResult,1))],[floor(hPlot(ComptResult-1,2)),floor(hPlot(ComptResult,2))],'-m','linewidth',2)
            plot([floor(hPlot(ComptResult-1,1)),floor(hPlot(ComptResult,1))],[floor(hPlot(ComptResult-1,2)),floor(hPlot(ComptResult,2))],'-k','linewidth',1)
        end
        ComptResult = ComptResult + 1;
    end
end
    
% Trois points minimum...
if length(h(:,1)) < 3
    CodeTxt = [10,11];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(11))]);
    return
end
    
% new V1.4.1
plot([floor(hPlot(1,1)),floor(hPlot(end,1))],[floor(hPlot(1,2)),floor(hPlot(end,2))],'-m','linewidth',2)
plot([floor(hPlot(1,1)),floor(hPlot(end,1))],[floor(hPlot(1,2)),floor(hPlot(end,2))],'-k','linewidth',1)

[LinS,ColS] = size(Quanti(LaQuelle).elem(1).quanti); % first element ref
MasqueSel = Xpoly2maskX(h(:,1),h(:,2),LinS,ColS);

% Preparation to detect Pixels values of zero (MasqueFilter variable)     % New 1.6.4
TheSumMaps = zeros(size(Quanti(LaQuelle).elem(1).quanti,1),size(Quanti(LaQuelle).elem(1).quanti,2));
MasqueFilter = zeros(size(Quanti(LaQuelle).elem(1).quanti,1),size(Quanti(LaQuelle).elem(1).quanti,2));
for i=1:length(Quanti(LaQuelle).elem)
    TheSumMaps= TheSumMaps + Quanti(LaQuelle).elem(i).quanti;
end

MasqueFilter(find(TheSumMaps > 0)) = ones(length(find(TheSumMaps > 0)),1);    

for i=1:length(Quanti(LaQuelle).elem)
    LesVals = Quanti(LaQuelle).elem(i).quanti(:);
    LesVals = LesVals + 0.0000001;
    LesValsOk = LesVals .* MasqueSel(:).*MasqueFilter(:);
    LaMoy(i) = mean(LesValsOk(find(LesValsOk > 0))); % NaNs are rejected.
end

CodeTxt = [10,8];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(8))]);

[Success,Message,MessageID] = mkdir('Exported-LocalCompos');

cd Exported-LocalCompos
[Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export Bulk-compo as');
cd ..

if ~Directory
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(4))]);
    return
end


fid = fopen(strcat(pathname,Directory),'w');
fprintf(fid,'%s\n\n','Local composition (Area) from XMapTools');
for i = 1:length(ListName)
    fprintf(fid,'%s\t',[char(ListName(i))]);
    fprintf(fid,'%s\n',[num2str(LaMoy(i))]);
end

fprintf(fid,'\n');

fprintf(fid,'%s\t',['SUM']);
fprintf(fid,'%s\n',[num2str(sum(LaMoy))]);

fclose(fid);

CodeTxt = [10,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(10).txt(9))]);

    
return


% #########################################################################
%       EXPORT OX W% V1.6.2                                        26.02.13
 function QUbutton2_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;
ValMin = get(handles.QUppmenu2,'Value');
if ValMin == 1, return, end

ListName = Quanti(ValMin).listname;


% - - - - - - - - - - SELECT THE MODE - - - - - - - - - - 

CodeTxt = [11,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(1))]);


Mode = menu('Export Wt.% compositions of',{ ...
                           '[1] All pixels', ...
                           '[2] Area (selection)', ...
                           '[3] Random pixels', ...
                           '[4] Average of groups (maskfile)', ...
                           '[5] All of a group (maskfile)', ...
                           '[6] Average of a group (maskfile)', ...
                           '[7] Average of all pixels'});
                  
% WARNING NEW ORDER VER_XMAPTOOLS_750 2.1.1

%[Mode,Ok] = listdlg('ListString',Mode,'name','Mode','SelectionMode','Single','InitialValue',5);

if ~Mode
    CodeTxt = [11,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
    return
end


% - - - - -  SELECT THE ELEMENT ORDER (in exported file) - - - - - 

CodeTxt = [11,3];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(3))]);
% Default: 
Order = {'Ref','SiO2','TiO2','Al2O3','FeO','Fe2O3','MnO','MgO','CaO','Na2O','K2O','Fe3'};

Text=''; 
for i =1:length(Order)
    Text = strcat(Text,Order(i),'-');
end
options.Resize='on';
Text = inputdlg('Order to export','Input',8,Text,options);

if ~length(Text)
    CodeTxt = [11,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
    return
end

if ~isequal(Text{1}(1:3),'Ref')
    CodeTxt = [11,14];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end


% The seperated oxydes
Order = strread(char(Text),'%s','delimiter','-');

% find in database the solutions             (saved into the variable 'ou')
[Est,Ou] = ismember(Order,ListName);

% Size of map
[LinS,ColS] = size(Quanti(ValMin).elem(1).quanti);

ForSuite = 1;


% - - - - - - - - - - IF MODE - - - - - - - - - - 


switch Mode
    
    case 1 % All pixels
        MasqueSel = ones(LinS,ColS);
        
        
        
    case 2 % Area (selection)
        CodeTxt = [11,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(4))]);
        clique = 1;
        ComptResult = 1;
        axes(handles.axes1); hold on

        while clique < 2
            [a,b,clique] = XginputX(1,handles);
            [aFig,bFig] = CoordinatesFromRef(a,b,handles);
            if clique < 2
                h(ComptResult,1) = a;
                h(ComptResult,2) = b;
                hPlot(ComptResult,1) = aFig;             % for display (Fig coordinate system)
                hPlot(ComptResult,2) = bFig;                                       % new 1.6.2
                plot(floor(hPlot(ComptResult,1)),floor(hPlot(ComptResult,2)),'.w') % New 1.6.2
                %plot(floor(h(ComptResult,1)),floor(h(ComptResult,2)),'.w') % point
                if ComptResult >= 2 % start
                    plot([floor(hPlot(ComptResult-1,1)),floor(hPlot(ComptResult,1))],[floor(hPlot(ComptResult-1,2)),floor(hPlot(ComptResult,2))],'-k')
                end
                ComptResult = ComptResult + 1;
            end
        end

        % Trois points minimum...
        if length(h(:,1)) < 3
            CodeTxt = [11,5];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(5))]);
            return
        end

        % new V1.4.1
        plot([floor(hPlot(1,1)),floor(hPlot(end,1))],[floor(hPlot(1,2)),floor(hPlot(end,2))],'-k')
        MasqueSel = Xpoly2maskX(h(:,1),h(:,2),LinS,ColS);
        
        
        
    case 3 % Random pixels
        CodeTxt = [11,6];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(6))]);

        NbPoints = inputdlg('How many ?','Input',1,{'50'});

        if ~length(NbPoints)
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
            return
        end

        NbPoints =  str2num(char(NbPoints));

        MasqueSel = zeros(LinS,ColS); % defaut
        Compt = 0;

        axes(handles.axes1);
        while Compt <= NbPoints
            RandCoor =[round(rand*LinS),round(rand*ColS)]; 

            if RandCoor(1) < 1, RandCoor(1) =1; end
            if RandCoor(2) < 1, RandCoor(2) =1; end

            LaSum = 0;
            for i=1:length(Quanti(ValMin).elem)
                LaSum = LaSum + Quanti(ValMin).elem(i).quanti(RandCoor(1),RandCoor(2));
            end

            if LaSum > 50 && LaSum < 105
                Compt=Compt+1;
                MasqueSel(RandCoor(1),RandCoor(2)) = 1;
                [DispCoor(2),DispCoor(1)] = CoordinatesFromRef(RandCoor(2),RandCoor(1),handles);   % new 1.6.2
                hold on, plot(DispCoor(2),DispCoor(1),'o','linewidth',2,'MarkerEdgeColor','w','MarkerFaceColor','k','markersize',8);
            end
        end

        
    case 4 % Average of groups (maskfile)
        
        % ------- Load a maskfile -------
        
        % New 2.1.1 - Users must now use a mask file !!!
        % That's stupid to generate one using kmeans when Chemical modules
        % can be used in all the workspaces in 2.1. 
    
        CodeTxt = [11,13];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(13))]);

        [Success,Message,MessageID] = mkdir('Maskfiles');

        cd Maskfiles
            [Directory, pathname] = uigetfile({'*.txt', 'TXT Files (*.txt)'}, 'Select a maskfile');
        cd ..

        if Directory
            Groups = load([char(pathname),'/',char(Directory)]);
            NbMask = max(max(Groups));
            SizeMap = size(Groups);
        else 
            CodeTxt = [11,15];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            return
        end

        for i = 1:length(Quanti(ValMin).elem)
            Chemic(:,i) = Quanti(ValMin).elem(i).quanti(:);
            SizeMap = size(Quanti(ValMin).elem(i).quanti);
        end

        hold off
        cla(handles.axes1)
        axes(handles.axes1)
        imagesc(XimrotateX(Groups,handles.rotateFig)), axis image
        GraphStyle(hObject, eventdata, handles);
        set(handles.axes1,'xtick',[], 'ytick',[]);
        
        for i=1:NbMask
            NameMask{i} = num2str(i);
        end
        
        colormap([0,0,0;hsv(NbMask-1)]);
        
        hcb = colorbar('YTickLabel',NameMask(:)); caxis([1 NbMask+1]);
        set(hcb,'YTickMode','manual','YTick',[1.5:1:NbMask+1]);


        % Il faut récupérer les moyennes
        for i=1:NbMask

            for j = 1:length(Chemic(1,:)) % Elements
                LeMulti = Groups == i;
                LesData = LeMulti .* Quanti(ValMin).elem(j).quanti;
                LesGoodData = LesData(find(LesData > 0.001));
                if LesGoodData
                    LaMoy(i,j) = median(LesGoodData);
                    %keyboard
                else
                    LaMoy(i,j) = 0;
                end
            end
        end

        % POUR AFFICHER
    %     figure
    %     plot(LesGoodData,LesGoodData+randn(length(LesGoodData),1).*1,'.','markersize',1), hold on
    %     plot(LaMoy(i,j),LaMoy(i,j),'+r')

        Compt = 0;
        for iAna = 1:length(LaMoy(:,1))
            Compt = Compt+1;
            for j = 1:length(Order)
                if Est(j)
                        Export(Compt,j) = LaMoy(iAna,Ou(j));
                    else
                        Export(Compt,j) = 0;
                end

                Export(Compt,1) = iAna;
            end
        end

        ForSuite = 0;
        
        
        
    case 5 % All of a group (maskfile)
        
        % ------- Load  a maskfile -------
    
        CodeTxt = [11,13];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        [Success,Message,MessageID] = mkdir('Maskfiles');

        cd Maskfiles
            [Directory, pathname] = uigetfile({'*.txt', 'TXT Files (*.txt)'}, 'Select a maskfile');
        cd ..

        if Directory
            Groups = load([char(pathname),'/',char(Directory)]);
            NbMask = max(max(Groups));
            SizeMap = size(Groups);
        else
            CodeTxt = [11,15];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            return
        end

        for i = 1:length(Quanti(ValMin).elem)
            Chemic(:,i) = Quanti(ValMin).elem(i).quanti(:);
            SizeMap = size(Quanti(ValMin).elem(i).quanti);
        end

        hold off
        cla(handles.axes1)
        axes(handles.axes1)
        imagesc(XimrotateX(Groups,handles.rotateFig)), axis image
        GraphStyle(hObject, eventdata, handles);
        set(handles.axes1,'xtick',[], 'ytick',[]);
        
        for i=1:NbMask
            NameMask{i} = num2str(i);
        end
        
        colormap([0,0,0;hsv(NbMask-1)]);
        
        hcb = colorbar('YTickLabel',NameMask(:)); caxis([1 NbMask+1]);
        set(hcb,'YTickMode','manual','YTick',[1.5:1:NbMask+1]);
        
        
        % User must select a mask
        
        
        [s,v] = listdlg('PromptString','Select a phase:',...
                      'SelectionMode','single',...
                      'ListString',NameMask);
                  
        if ~v 
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            return
        end
        
        MasqueSel = zeros(LinS,ColS);
        MasqueSel(find(Groups(:) == s)) = ones(length(find(Groups(:) == s)),1);
        
        
    case 6 % Average of a group (maskfile)
    
        CodeTxt = [11,13];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        [Success,Message,MessageID] = mkdir('Maskfiles');

        cd Maskfiles
            [Directory, pathname] = uigetfile({'*.txt', 'TXT Files (*.txt)'}, 'Select a maskfile');
        cd ..

        if Directory
            Groups = load([char(pathname),'/',char(Directory)]);
            NbMask = max(max(Groups));
            SizeMap = size(Groups);
            MaskFileName = Directory;
        else
            CodeTxt = [11,15];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            return
        end

        for i = 1:length(Quanti(ValMin).elem)
            Chemic(:,i) = Quanti(ValMin).elem(i).quanti(:);
            SizeMap = size(Quanti(ValMin).elem(i).quanti);
        end

        hold off
        cla(handles.axes1)
        axes(handles.axes1)
        imagesc(XimrotateX(Groups,handles.rotateFig)), axis image
        GraphStyle(hObject, eventdata, handles);
        set(handles.axes1,'xtick',[], 'ytick',[]);
        
        for i=1:NbMask
            NameMask{i} = num2str(i);
        end
        
        colormap([0,0,0;hsv(NbMask-1)]);
        
        hcb = colorbar('YTickLabel',NameMask(:)); caxis([1 NbMask+1]);
        set(hcb,'YTickMode','manual','YTick',[1.5:1:NbMask+1]);

        
        [s,v] = listdlg('PromptString','Select a phase:',...
                      'SelectionMode','single',...
                      'ListString',NameMask);
                  
        if ~v 
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            return
        end
        
        MasqueSel = zeros(LinS,ColS);
        MasqueSel(find(Groups(:) == s)) = ones(length(find(Groups(:) == s)),1);
        
        for i = 1:length(Order)                  % each elements to be exported
            if Est(i)

                % [1] Mean
                Export(i,1) = mean(Quanti(ValMin).elem(Ou(i)).quanti(find(MasqueSel)));
                % [2] Standard deviation
                Export(i,2) = std(Quanti(ValMin).elem(Ou(i)).quanti(find(MasqueSel)));
                % [3] Median
                Export(i,3) = median(Quanti(ValMin).elem(Ou(i)).quanti(find(MasqueSel)));

            else

                % unknow element
                Export(i,1) = 0;
                Export(i,2) = 0;
                Export(i,3) = 0;

            end


            % reference

            Export(1,1) = 0;             % here the reference is zero (average)
            Export(1,2) = 0;             % here the reference is zero (average)
            Export(1,3) = 0;             % here the reference is zero (average)
        end


        % SAVE THE RESULT...                      (paste and edited from above)
        CodeTxt = [11,8];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        [Success,Message,MessageID] = mkdir('Exported-Oxides');

        cd Exported-Oxides
        [Directory, pathname] = uiputfile({'*.txt', 'TEXT File (*.txt)'}, 'Save results as');
        cd ..

        if ~Directory
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            return    
        end

        fid = fopen(strcat(pathname,Directory),'w');

        CodeTxt = [11,9];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(9))]);
        SepList = {'Blank','Tabulation'};
        [Sel,Ok] = listdlg('ListString',SepList,'name','delimiter','SelectionMode','Single','InitialValue',2);
        if ~Ok
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
            return
        end


        fprintf(fid,'%s\n','Oxide [Average] group compositions (Wt%) from XMapTools');
        fprintf(fid,'%s\n',date);
        fprintf(fid,'%s\n',['Standardized phase: ',char(Quanti(ValMin).mineral)]);
        fprintf(fid,'%s\n',['Maskfile: ',char(MaskFileName)]);
        fprintf(fid,'%s\n',['Selected group: ',char(num2str(s))]);
        fprintf(fid,'%s\n\n\n',['Nb analyses: ',char(num2str(length(find(MasqueSel(:)))))]);
        
        %fprintf(fid,'%s\n\n',['Order: ',char(Text)]);    % MAJ 1.6.1 -- 4.01.13

        fprintf(fid,'%s\n','        [Mean]  [Std]   [Median]');
        for i=1:length(Export(:,1))
            switch Sel
                case 1
                    fprintf(fid,'%s %.2f %.2f %.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                case 2
                    if length(Order{i}) > 3
                        fprintf(fid,'%s\t%.2f\t%.2f\t%.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                    else
                        fprintf(fid,'%s\t\t%.2f\t%.2f\t%.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                    end
            end

        end

        fclose(fid);

        CodeTxt = [11,10];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Quanti(ValMin).mineral),') ']); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(10)),' (',char(Quanti(ValMin).mineral),') ']);
        guidata(hObject,handles);       

        return
        
        
    case 7  % Average of all pixels
        
        % New 1.6.2 (P. Lanari 28.02.13)
    
        % This method is better than only one group in meth. [4] (used before). 

        % We calculate the values, write the file and return in this loop... 
        % Because this mode is strongly different than the other in the same
        % function... 

        MasqueSel = ones(LinS,ColS);                 % we select all the pixels

        for i = 1:length(Order)                  % each elements to be exported
            if Est(i)

                % [1] Mean
                Export(i,1) = mean(Quanti(ValMin).elem(Ou(i)).quanti(find(Quanti(ValMin).elem(Ou(i)).quanti(:))));
                % [2] Standard deviation
                Export(i,2) = std(Quanti(ValMin).elem(Ou(i)).quanti(find(Quanti(ValMin).elem(Ou(i)).quanti(:))));
                % [3] Median
                Export(i,3) = median(Quanti(ValMin).elem(Ou(i)).quanti(find(Quanti(ValMin).elem(Ou(i)).quanti(:))));

            else

                % unknow element
                Export(i,1) = 0;
                Export(i,2) = 0;
                Export(i,3) = 0;

            end


            % reference

            Export(1,1) = 0;             % here the reference is zero (average)
            Export(1,2) = 0;             % here the reference is zero (average)
            Export(1,3) = 0;             % here the reference is zero (average)
        end


        % SAVE THE RESULT...                      (paste and edited from above)
        CodeTxt = [11,8];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        [Success,Message,MessageID] = mkdir('Exported-Oxides');

        cd Exported-Oxides
        [Directory, pathname] = uiputfile({'*.txt', 'TEXT File (*.txt)'}, 'Save results as');
        cd ..

        if ~Directory
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            return    
        end

        fid = fopen(strcat(pathname,Directory),'w');

        CodeTxt = [11,9];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(9))]);
        SepList = {'Blank','Tabulation'};
        [Sel,Ok] = listdlg('ListString',SepList,'name','delimiter','SelectionMode','Single','InitialValue',2);
        if ~Ok
            CodeTxt = [11,2];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
            return
        end


        fprintf(fid,'%s\n','Oxide [Average] mineral compositions (Wt%) from XMapTools');
        fprintf(fid,'%s\n',date);
        fprintf(fid,'%s\n\n\n',['Standardized phase: ',char(Quanti(ValMin).mineral)]);
        %fprintf(fid,'%s\n\n',['Order: ',char(Text)]);    % MAJ 1.6.1 -- 4.01.13

        fprintf(fid,'%s\n','        [Mean]  [Std]   [Median]');
        for i=1:length(Export(:,1))
            switch Sel
                case 1
                    fprintf(fid,'%s %.2f %.2f %.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                case 2
                    if length(Order{i}) > 3
                        fprintf(fid,'%s\t%.2f\t%.2f\t%.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                    else
                        fprintf(fid,'%s\t\t%.2f\t%.2f\t%.2f\n',Order{i},Export(i,1),Export(i,2),Export(i,3));
                    end
            end

        end

        fclose(fid);

        CodeTxt = [11,10];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Quanti(ValMin).mineral),') ']); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(10)),' (',char(Quanti(ValMin).mineral),') ']);
        guidata(hObject,handles);       

        return
        
end



if ForSuite

    % Here new procedure VER_XMapTools_750 2.1
    
    % (1) Create MatCompo from the good quanti 
    for i = 1:length(Quanti(ValMin).elem)
        MatCompo(:,i) = Quanti(ValMin).elem(i).quanti(:);
    end

    MatCompo = MatCompo .* repmat(MasqueSel(:),1,length(Quanti(ValMin).elem)); 
    
    % (2) Generate the Sum and find the good ones
    TheSum = sum(MatCompo,2);
    TheOK = find(TheSum(:) > 50 & TheSum(:) < 200);

    Export = zeros(length(TheOK),length(Order));

    Export(:,find(Ou)) = MatCompo(TheOK,Ou(find(Ou)));
    Export(:,1) = TheOK;

% if ForSuite & 0
% 
%     WaitBarPerso(0, hObject, eventdata, handles);
% 
%     howMuch = length(find(Quanti(ValMin).elem(1).quanti));
%     Export = zeros(howMuch,length(Order));
% 
%     hCompt =0;
%     Compt = 0;
%     for i = 1:length(Quanti(ValMin).elem(1).quanti(:))
%         hCompt = hCompt+1;
%         if hCompt == 750
%             WaitBarPerso(i/length(Quanti(ValMin).elem(1).quanti(:)), hObject, eventdata, handles)
%     
%             CodeTxt = [11,7];
%             set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(round(i/length(Quanti(ValMin).elem(1).quanti(:))*100)),'%)']); 
%             TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
% 
%             % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(7)),' (',num2str(round(i/length(Quanti(ValMin).elem(1).quanti(:))*100)),'%)']);
%             drawnow;
%             hCompt = 0;
%         end
%         SumI = 0;
%         for k = 1:length(Quanti(ValMin).elem)
%             SumI = SumI + Quanti(ValMin).elem(k).quanti(i)*MasqueSel(i);
%         end
% 
%         if SumI > 50 && SumI < 105
%             Compt = Compt + 1;
%             % good analysis 
%             for j=1:length(Order)
% 
%                 if Est(j)
%                     Export(Compt,j) = Quanti(ValMin).elem(Ou(j)).quanti(i);
%                 else
%                     Export(Compt,j) = 0;
%                 end
% 
%                 Export(Compt,1) = i; % reference
% 
%             end
%         end
% 
%     end
%     
%     WaitBarPerso(1, hObject, eventdata, handles)
%     CodeTxt = [11,7];
%     set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (100 %)']); 
%     TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
% 
%     %set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(7)),' (100 %)']);


else
    % Alors on peut enregistrer un fichier masque pour 
    % pouvoir le charger dans les modules 3D et 2D
    % C'est je pense la solution la plus simple pour l'instant
    % car c'est compliqué de gérer un fichier masque en plus (et pas
    % forcement utile). A finir ici
    
    if ~Directory
        CodeTxt = [11,12];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(12))]);

        [Success,Message,MessageID] = mkdir('Maskfiles');

        cd Maskfiles
        [Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export maskfile as');
        cd ..
        
        if Directory
            save([char(pathname),'/',char(Directory)],'Groups','-ASCII');
        end
    end
    
end

% Pour corriger certains bugs, temporaire...
%ExportFinal = Export(1:Compt,:);
%clear Export
%Export = ExportFinal;

% NEW 1.4.1
CodeTxt = [11,8];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

[Success,Message,MessageID] = mkdir('Exported-Oxides');

cd Exported-Oxides
[Directory, pathname] = uiputfile({'*.txt', 'TEXT File (*.txt)'}, 'Save results as');
cd ..

if ~Directory
    CodeTxt = [11,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return    
end

% CodeTxt = [11,8];
% set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
% TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
% 
% % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(8))]);
% 
% %Save a file: 
% [Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export as');
% if ~Directory
%     CodeTxt = [11,2];
%     set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
%     TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
% 
%     % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
%     return
% end 

fid = fopen(strcat(pathname,Directory),'w');

CodeTxt = [11,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(9))]);
SepList = {'Blank','Tabulation'};
[Sel,Ok] = listdlg('ListString',SepList,'name','Delimiter','SelectionMode','Single','InitialValue',1);
if ~Ok
    CodeTxt = [11,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(2))]);
    return
end

fprintf(fid,'%s\n','Oxide mineral compositions (Wt%) from XMapTools');
fprintf(fid,'%s\n',date);
fprintf(fid,'%s\n',['Analyses: ',char(num2str(length(Export(:,1)))),]);
fprintf(fid,'%s\n',['Standardized phase: ',char(Quanti(ValMin).mineral)]);
fprintf(fid,'%s\n\n',['Order: ',char(Text)]);    % MAJ 1.6.1 -- 4/01/13

WaitBarPerso(0, hObject, eventdata, handles);
hCompt = 0;
if Sel == 1
    for i =1:length(Export(:,1))
        
        hCompt = hCompt+1;
        if hCompt == 2000;
            WaitBarPerso(i/length(Export(:,1)), hObject, eventdata, handles)
    
            CodeTxt = [11,7];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(round(i/length(Export(:,1))*100)),'%)']); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(7)),' (',num2str(round(i/length(Quanti(ValMin).elem(1).quanti(:))*100)),'%)']);
            drawnow;
            hCompt = 0;
        end
        
        fprintf(fid,'%.2f \b',Export(i,1:end-1));
        fprintf(fid,'%.2f\n',Export(i,end));

    end
else
    for i =1:length(Export(:,1))
        
        hCompt = hCompt+1;
        if hCompt == 2000;
            WaitBarPerso(i/length(Export(:,1)), hObject, eventdata, handles)
    
            CodeTxt = [11,7];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',num2str(round(i/length(Export(:,1))*100)),'%)']); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(7)),' (',num2str(round(i/length(Quanti(ValMin).elem(1).quanti(:))*100)),'%)']);
            drawnow;
            hCompt = 0;
        end
        
        fprintf(fid,'%.2f\t',Export(i,1:end-1));
        fprintf(fid,'%.2f\n',Export(i,end));

    end
end
WaitBarPerso(1, hObject, eventdata, handles);   

fclose(fid);

CodeTxt = [11,10];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Quanti(ValMin).mineral),') ']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(10)),' (',char(Quanti(ValMin).mineral),') ']);
guidata(hObject,handles);
return


% #########################################################################
%       BULK PROPORTIONS (1.6.2)
function QUbutton9_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

% Liste des noms de carte
for i=1:length(Quanti)-1
    ListMaps(i) = Quanti(i+1).mineral;
end

CodeTxt = [10,13];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

UserNbMin = str2num(char(inputdlg('Number of minerals','Input',1,{'3'})));

if ~length(UserNbMin)
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

for i=1:UserNbMin
    ListMin{i} = ['mineral ',char(num2str(i))];
    ListProp{i} = char(int2str((100/UserNbMin)));
end 
ListProp{end} = num2str(100-round(100/UserNbMin)*(UserNbMin-1));

CodeTxt = [10,14];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

ListMin = inputdlg(ListMin,'Input',1,ListMin);

if ~length(ListMin)
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

CodeTxt = [10,15];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

ListProp = str2num(char(inputdlg(ListMin,'Proportions',1,ListProp)));

while sum(ListProp) ~= 100
    % new sum required...
    LaSum = sum(ListProp);
    for i = 1:length(ListProp)
        ListProp(i) = round(ListProp(i)/LaSum*100);
    end
    ListProp(end) = 100-(sum(ListProp(1:end-1)));
    
    for i=1:length(ListProp)
        DefListProp{i} = num2str(ListProp(i));
    end
    
    CodeTxt = [10,17];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    ListProp = str2num(char(inputdlg(ListMin,'Proportions',1,DefListProp)));
        
    if ~length(ListProp)
        CodeTxt = [10,4];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        return
    end
end

if ~length(ListProp)
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

% Selection des points de départ...
for i = 1:UserNbMin
    
    CodeTxt = [10,16];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(ListMin(i))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    [lesLin(i),lesCol(i)] = XginputX(1,handles);
    
    [aPlot,bPlot] = CoordinatesFromRef(lesLin(i),lesCol(i),handles);
    
    axes(handles.axes1), hold on
    plot(aPlot,bPlot, 'mo','linewidth', 2)
    
end  
lesLin = round(lesLin);
lesCol = round(lesCol);

hold off

% Chemical system
laQuanti = get(handles.QUppmenu2,'Value');

for i = 1:length(Quanti(laQuanti).elem)
    % for each element
    lesNamesQuanti{i} = Quanti(laQuanti).elem(i).name;
    
    for j = 1:length(lesLin)
        lesData(i,j) = Quanti(laQuanti).elem(i).quanti(lesCol(j),lesLin(j));
    end
end

ListProp = ListProp/100;
% good scale, 

BulkCompo = zeros(length(lesData(:,1)),1);

for i=1:length(lesData(:,1)) % ielem
    for j = 1:length(lesData(1,:)) % iCompos
        BulkCompo(i) = BulkCompo(i) + ListProp(j)*lesData(i,j);
    end
end

ListElems = Quanti(laQuanti).listname;

% Save
CodeTxt = [10,8];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

[Success,Message,MessageID] = mkdir('Exported-LocalCompos');

cd Exported-LocalCompos
[Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export Local-compo as');
cd ..

if ~Directory
    CodeTxt = [10,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    return
end

%keyboard

fid = fopen(strcat(pathname,Directory),'w');
fprintf(fid,'%s\n\n','Local composition (Proportions) from XMapTools');

fprintf(fid,'%s\n','(1) Mineral proportions:');
for i =1:length(ListMin)
    fprintf(fid,'%s\t',[char(ListMin(i))]);
    fprintf(fid,'%s\n',[num2str(ListProp(i)*100)]);
end

fprintf(fid,'\n\n');

fprintf(fid,'%s\n','(2) Mineral compositions:');
fprintf(fid,'\t');
for i = 1:length(ListMin)
    fprintf(fid,'%s\t',[char(ListMin{i})]);
end
fprintf(fid,'\n');

for i=1:length(ListElems)
    fprintf(fid,'%s\t',[char(ListElems{i})]);
    
    for j = 1:UserNbMin
        fprintf(fid,'%s\t',[char(num2str(lesData(i,j)))]);
    end
    fprintf(fid,'\n');
end

fprintf(fid,'\n\n');

fprintf(fid,'%s\n','(3) Local Composition:');

for i =1:length(ListElems)
    fprintf(fid,'%s\t',[char(ListElems{i})]);
    fprintf(fid,'%s\n',[num2str(BulkCompo(i))]);
end

fclose(fid);

CodeTxt = [10,9];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);



return


% #########################################################################
%       INTERPLOATION BOUNDARIES OR NOT ??? (NEW 1.6.1)
function MergeInterpBoundaries_Callback(hObject, eventdata, handles)
return


% #########################################################################
%       THERMOMETRY MINERAL LIST V1.4.1
function THppmenu1_Callback(hObject, eventdata, handles)

externalFunctions = handles.externalFunctions; 
weAreType = get(handles.THppmenu3,'Value');
minRef = get(handles.THppmenu1,'Value');  

set(handles.THppmenu2,'String',externalFunctions(weAreType).minerals(minRef).listMeth);
set(handles.THppmenu2,'Value',1);

guidata(hObject,handles);
return


% #########################################################################
%       SELECT THE TYPE OF CALCULATION (NEW 1.6.5)
function THppmenu3_Callback(hObject, eventdata, handles)
externalFunctions = handles.externalFunctions;

weAreGoingTo = get(handles.THppmenu3,'Value');

if weAreGoingTo == 5
    
    set(handles.THppmenu1,'visible','off');
    set(handles.THppmenu2,'visible','off');
    %set(handles.text28,'visible','off');
    %set(handles.text29,'visible','off');
    set(handles.THbutton1,'visible','off');
    set(handles.THbutton2,'visible','off');
    
    % Activate the menus for XThermoTools... 
    
    % XThermoTools is available only if there is more than 3 Qminerals and
    % at least one maskfile.
    if handles.XThermoToolsACTIVATION
    
        if length(get(handles.QUppmenu2,'String')) > 3 && handles.MaskFile(1).type
            %set(handles.text28,'visible','on','String','Maskfile','enable','on');
            set(handles.THppmenu4,'visible','on','String',get(handles.PPMenu3,'String'),'Value',get(handles.PPMenu3,'Value'),'enable','on');
            set(handles.THbutton3,'visible','on','enable','on');
        else
            %set(handles.text28,'visible','on','String','Maskfile','enable','off');
            set(handles.THppmenu4,'visible','on','String',get(handles.PPMenu3,'String'),'Value',get(handles.PPMenu3,'Value'),'enable','off');
            set(handles.THbutton3,'visible','on','enable','off'); 

        end
        
    else
        set(handles.text_XThermoTools,'visible','on');
    end
    % Message XThermoTools is not available...
    %set(handles.text_XThermoTools,'visible','on');
    
    % Here will be the calling function to XThermoTools
    
else
    set(handles.THppmenu1,'visible','on');
    set(handles.THppmenu2,'visible','on');
    %set(handles.text28,'visible','on','String','Mineral');
    %set(handles.text29,'visible','on');
    set(handles.THbutton1,'visible','on');
    set(handles.THbutton2,'visible','on');
    set(handles.text_XThermoTools,'visible','off');
    
    set(handles.THppmenu4,'visible','off');
    set(handles.THbutton3,'visible','off')
    
    oldListMineralName = get(handles.THppmenu1,'String');
    selectedMineralName = oldListMineralName(get(handles.THppmenu1,'value'));

    listMinDestination = externalFunctions(weAreGoingTo).listMin;

    Ou = find(ismember(listMinDestination,selectedMineralName));
    if isempty(Ou)
        minDestination = 1;
    else
        minDestination = Ou;  % same mineral
    end
    
    set(handles.THppmenu1,'String',listMinDestination)
    set(handles.THppmenu1,'Value',minDestination);

    set(handles.THppmenu2,'String',externalFunctions(weAreGoingTo).minerals(minDestination).listMeth);
    %set(handles.THppmenu2,'Value',1);   
    % REMOVED v2.1.1 because this change the Function selected when we
    % change the Qmineral !!!
        
end

guidata(hObject, handles);
return
    

% #########################################################################
%       CALCULATION INFOS
function THbutton2_Callback(hObject, eventdata, handles)

externalFunctions = handles.externalFunctions; 
weAreType = get(handles.THppmenu3,'Value');
minRef = get(handles.THppmenu1,'Value');  
methRef = get(handles.THppmenu2,'Value');

XMTFunctionsInfos(externalFunctions,weAreType,minRef,methRef);

return


% #########################################################################
%       FILTER 
function QUbutton8_Callback(hObject, eventdata, handles)
Quanti = handles.quanti;

TheQuanti = get(handles.QUppmenu2,'Value'); % for "none"
TheElem = get(handles.QUppmenu1,'Value');

NewPos = length(Quanti) + 1;
Quanti(NewPos) = Quanti(TheQuanti);


Quanti(NewPos).mineral = {[char(Quanti(NewPos).mineral),'_filter']};

Min = str2num(get(handles.ColorMin,'String'));
Max = str2num(get(handles.ColorMax,'String'));


LaMapRef = Quanti(NewPos).elem(TheElem).quanti;

LaMatTriage = zeros(size(LaMapRef));

lesGood = find(LaMapRef > Min & LaMapRef < Max);

LaMatTriage(lesGood) = ones(length(lesGood),1);

for i = 1:length(Quanti(NewPos).elem)
    Quanti(NewPos).elem(i).quanti = Quanti(NewPos).elem(i).quanti .* LaMatTriage;
    
end

% ---------- Update Mineral Menu QUppmenu2 ---------- 
for i=1:length(Quanti)
    NamesQuanti{i} = char(Quanti(i).mineral);
end

set(handles.QUppmenu2,'String',NamesQuanti); 
set(handles.QUppmenu2,'Value',NewPos);

handles.quanti = Quanti;

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
QUppmenu2_Callback(hObject, eventdata, handles)


% #########################################################################
%       XTHERMOTOOLS (1.7.1)
function THbutton3_Callback(hObject, eventdata, handles)
% (1) check if XThermoTools is available on this computer...
TheAnswer = exist('XThermoTools');

if TheAnswer ~= 2 && TheAnswer ~= 6
    warndlg({'XThermoTools is not installed on this computer.','Run the Launcher to download and install XThermoTools.'},'Warning')
    return
end

% Data to be sended

TheMaskFile = handles.MaskFile(get(handles.PPMenu3,'Value'));
TheQuanti = handles.quanti(get(handles.QUppmenu2,'Value'));

TheQuanti.listname = upper(TheQuanti.listname);   % XThermoTools use UPPERCASE


% Run VER_XMapTools_750 with the values from VER_XMapTools_750
XThermoTools(TheQuanti,TheMaskFile)

% So here ver_xmaptools_750 is still active and can be use in parallel with XThermoTools. 
% This is a good news. 
% P. Lanari (17.07.13). 
%
return




% -------------------------------------------------------------------------
% 6) RESULT FONCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%       THERMOMETERS LIST V1.4.1
function THppmenu2_Callback(hObject, eventdata, handles)

return


% #########################################################################
%       EXTERNAL FUNCTION COMPUTATION V1.6.4
function THbutton1_Callback(hObject, eventdata, handles)

% Updated in the version 1.6.4
% Compatible with area selection for: P, T and P-T spot mode. 

set(gcf, 'WindowButtonMotionFcn', '');
    
% Updated in the new version 1.6.2
% Compatible with the new list of methods

% ----------- Loaded external functions -----------
externalFunctions = handles.externalFunctions;

weAreType = get(handles.THppmenu3,'Value');
minRef = get(handles.THppmenu1,'Value');  
methodeRef = get(handles.THppmenu2,'Value');

selectedFunction = externalFunctions(weAreType).minerals(minRef).method(methodeRef);

%Choice = 1;
%Thermo = handles.thermo;
%ThermoMin = get(handles.THppmenu1,'Value'); % mineral
%ThermoMet = get(handles.THppmenu2,'Value'); % method
%Thermometers = Thermo(ThermoMin).thermometers(ThermoMet);


if weAreType == 3         % two or more minerals (spot mode)
    NbMin = 2;            % automatic setting 1.6.2
    
    %NbMin = Thermometers.type; % = number of mins
    
    CodeTxt = [14,11];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    ChoiceMenu = menu('method to select analyses:', 'Spot (single estimate)', 'Area (average estimate)'); % 1.6.4
    
    if ~ChoiceMenu
        CodeTxt = [14,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        axes(handles.axes1);
        set(gcf, 'WindowButtonMotionFcn', @mouseMove);
        return
    end
    
    %1) On affiche la bonne carte quanti avec les deux minéraux...
    lesElems = get(handles.QUppmenu1,'String');
    leElem = get(handles.QUppmenu1,'Value');
    
    CodeTxt = [14,8];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    [SelectedElem,Ok] = listdlg('ListString',lesElems,'SelectionMode','Single','InitialValue',leElem); 
    
    if ~Ok
        CodeTxt = [14,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        axes(handles.axes1);
        set(gcf, 'WindowButtonMotionFcn', @mouseMove);
        return
    end

    lesMaps = get(handles.QUppmenu2,'String');
    for i=2:length(lesMaps)
        lesMapsOk{i-1} = lesMaps{i};
    end
    leMap = get(handles.QUppmenu2,'Value');
    
    NamesMin = externalFunctions(weAreType).minerals(minRef).name;
    
    %NamesMin = Thermometers.mineral;
    lesNamesMin = strread(char(NamesMin),'%s','delimiter','+');
    
    for i=1:NbMin
        CodeTxt = [14,9];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' ',char(lesNamesMin{i})]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
        [TheSelectedMap,Ok] = listdlg('ListString',lesMapsOk,'SelectionMode','Single','InitialValue',leMap-1); 
        
        if ~Ok
            CodeTxt = [14,3];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
            
            axes(handles.axes1);
            set(gcf, 'WindowButtonMotionFcn', @mouseMove);
            return
        end 
        SelectedMaps(i) = TheSelectedMap;
    end
    
    
    if length(SelectedMaps) < NbMin %number of minerals
        CodeTxt = [14,10];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        axes(handles.axes1);
        set(gcf, 'WindowButtonMotionFcn', @mouseMove);
        return
    end
    
    SelectedMaps = SelectedMaps + 1; % required for indexation
    
    % Go building the newmap
    Quanti = handles.quanti;
    
    TheMap = zeros(size(Quanti(2).elem(1).quanti));
    for i=1:length(SelectedMaps)
        TheMap = TheMap + Quanti(SelectedMaps(i)).elem(SelectedElem).quanti;
    end
    
    CodeTxt = [11,17];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    figure, 
    imagesc(TheMap), colorbar vertical, axis image, colormap([0,0,0;jet(64)])
    set(gca,'XTick',[]); set(gca,'YTick',[]); 
    hold on, 
    
    % Preparation a l'indexation pour toutes les maps
    ListInput = selectedFunction.input;
    
    %ListInput = Thermometers.input;
    
    ComptAbsMap = 0;
    
    for i = 1:length(SelectedMaps)
        lesElemsDispo = Quanti(SelectedMaps(i)).listname;
        leMinTraite = Quanti(SelectedMaps(i)).mineral;
        
        for iElem = 1:length(ListInput)
            LeElem = ListInput(iElem);

            [oui,ou] = ismember(LeElem,lesElemsDispo); % map order
            
            % New test: have you this map ? (10/10)
            if oui
                DataElem = Quanti(SelectedMaps(i)).elem(ou).quanti(:);
            else
                ComptAbsMap = ComptAbsMap+1;
                DataElem = zeros(length(Quanti(SelectedMaps(i)).elem(1).quanti(:)),1);
                % En fait on cree une matrice de zeros sur la taille de
                % LaQuanti.elem(1) ou on est sur d'avoir une map. 
                ListAbsMap{ComptAbsMap} = LeElem;
            end
            Valeurs2Thermo(i).val(:,iElem) = DataElem;
        end
    end
    
    % Bon on a maintenant deux tableaux avec les analyses au bon format de
    % la fonction... Cool
    
    % 2) Preparation de la fonction eval pour pas le faire dans chaque
    % boucle
    
    % Eval to apply the thermometer...
    ListOutput = selectedFunction.output;
    
    %ListOutput = Thermometers.output;
    b = char(ListOutput);

    for i=1:size(b,1) % lines
        for j=1:size(b,2) % columns
            if i == 1 & j == 1 
                Text = '[';
                Text = strcat(Text,b(i,j));
            elseif i ~= 1 & j == 1
                Text = strcat(Text,',',b(i,j));
            elseif i ~= 1 & j ~= 1
                Text = strcat(Text,b(i,j));
            end
        end
    end

    Text = strcat(Text,']');
    Commande = char(strcat(Text,' = ',selectedFunction.file,'(CompoMin,handles,InputVariables);'));

    % from 1.6.4 we need to define InputVariables
    
    % 3) Selection des points
        
    % Decal en fonction taille image
    if length(TheMap(1,:)) > 700
        Decal(1) = 20;
    elseif length(TheMap(1,:)) > 400
        Decal(1) = 10;
    else
        Decal(1) = 5;
    end

    if length(TheMap(:,1)) > 700
        Decal(2) = 20;
    elseif length(TheMap(:,1)) > 400
        Decal(2) = 10;
    else
        Decal(2) = 5;
    end
    
    % Preparation de la sauvegarde...
    
    lesResults.method = selectedFunction.name;
    lesResults.minerals = NamesMin;
    
    %lesResults.method = Thermometers.name;
    %lesResults.minerals = Thermometers.mineral;

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if ChoiceMenu == 1                                  % spot mode (1.6.4)
    
        hold on,
        % New version 1.5.1 for selection and output... nbmin can be > 2...
        OnEnSelect = 1;
        ComptCouples = 0;

        while OnEnSelect

            % First mineral...
            title(['Select a ',char(lesNamesMin{1}),' or rigth clic to exit...'])
            [x,y,button] = ginput(1);  % here ginput because we are not in the GUI (Lanari 11/2012)

            Ou = (round(x)-1)*length(TheMap(:,1)) + round(y);    % this works because x are columns and y rows
            CompoMin(1,:) =  Valeurs2Thermo(1).val(Ou,:);
            
            if button == 3
                break
            else
                ComptCouples = ComptCouples+1;
                disp(['* * * Selection: ',num2str(ComptCouples)]);
                disp([char(lesNamesMin{1}),' (Compo)']);
                disp(num2str(CompoMin(1,:)));

    %             X1(ComptCouples) = x;
    %             Y1(ComptCouples) = y;

                leTxt = text(x-Decal(1),y-Decal(2),['C',num2str(ComptCouples)]);
                set(leTxt,'backgroundcolor',[1,1,1],'Color',[0,0,0],'FontName','Times New Roman','FontSize',8)
                hold on, plot(x,y,'o','MarkerEdgeColor','r','MarkerFaceColor','w')

                for iMin = 2:NbMin

                    title(['Select a ',char(lesNamesMin{iMin}),'...'])
                    [x,y] = ginput(1); % here ginput because we are not in the GUI (Lanari 11/2012)

                    Ou = (round(x)-1)*length(TheMap(:,1)) + round(y);
                    CompoMin(iMin,:) = Valeurs2Thermo(2).val(Ou,:); % A changer par la suite...

                    disp([char(lesNamesMin{iMin}),' (Compo)']);
                    disp(num2str(CompoMin(iMin,:)));

    %                 X2(ComptCouples) = x;
    %                 Y2(ComptCouples) = y;

                    leTxt = text(x-Decal(1),y-Decal(2),['C',num2str(ComptCouples)]);
                    set(leTxt,'backgroundcolor',[1,1,1],'Color',[0,0,0],'FontName','Times New Roman','FontSize',8)
                    hold on, plot(x,y,'o','MarkerEdgeColor','r','MarkerFaceColor','w')

                    if iMin == NbMin % Alors on peut calculer...

                        % Ask for input variables (1.6.4)
                        if length(char(selectedFunction.variables))
                            InputVariables = str2num(char(inputdlg(selectedFunction.variables,'Input',1,selectedFunction.varvals)));
                            
                            % Change the default answer
                            for k = 1:length(selectedFunction.varvals)
                                selectedFunction.varvals{k} = num2str(InputVariables(k));
                            end
                        else
                            InputVariables = [];
                        end

                        WaitBarPerso(0, hObject, eventdata, handles);
                      
                        eval(Commande);
                        
                        % Liste des variables de sortie (new 1.5.1)
                        TextAffich0 = ['Results (Test ',char(num2str(ComptCouples)),')'];
                        TextAffich = '... ';
                        for i=1:length(ListOutput)
                            eval(['LaValeur = ',num2str(ListOutput{i}),';']);
                            if LaValeur > 5
                                TextAffich = [char(TextAffich),char(ListOutput{i}),' = ',int2str(LaValeur),' ... '];
                            else
                                TextAffich = [char(TextAffich),char(ListOutput{i}),' = ',num2str(LaValeur,3),' ... '];
                            end
                        end    

                        %xlabel(['Couple ',num2str(ComptCouples),' - Temperature = ',num2str(T),' - ln(Kd) = ',num2str(ln_Kd)]);
                        xlabel({TextAffich0,TextAffich});

                        % Sauvegarde des resultats
                        lesResults.test(ComptCouples).oxides = CompoMin;
                        lesResults.test(ComptCouples).first = TextAffich0;
                        lesResults.test(ComptCouples).second = TextAffich;
                    end

                end

            end

        end
     
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    else
        % Choice Menu = 2                                    % area mode... 
        
        [LinS,ColS] = size(Quanti(2).elem(1).quanti);
        
        hold on,
        OnEnSelect = 1;
        ComptCouples = 1;
        
        % Ask for input variables (1.6.4)
        if length(char(selectedFunction.variables))
            InputVariables = str2num(char(inputdlg(selectedFunction.variables,'Input',1,selectedFunction.varvals)));

            % Change the default answer
            for k = 1:length(selectedFunction.varvals)
                selectedFunction.varvals{k} = num2str(InputVariables(k));
            end
        else
            InputVariables = [];
        end
        
        % while OnEnSelect    % Only one in this mode...

        % First mineral...
        title(['Select an area in ',char(lesNamesMin{1}),' or rigth clic to exit...'])

        h = [0];
        clique = 1;
        ComptResult = 1;
        while clique < 2
            [a,b,clique] = ginput(1);          % here ginput because we are not in the GUI !!!
            if clique < 2
                h(ComptResult,1) = a;
                h(ComptResult,2) = b;
                plot(floor(h(ComptResult,1)),floor(h(ComptResult,2)),'.w')
                if ComptResult >= 2 % start
                    plot([floor(h(ComptResult-1,1)),floor(h(ComptResult,1))],[floor(h(ComptResult-1,2)),floor(h(ComptResult,2))],'-k')
                end
                ComptResult = ComptResult + 1;
            end
        end

        % Trois points minimum...
        if length(h(:,1)) < 3
            CodeTxt = [11,5];
            set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
            TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

            % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(5))]);
            axes(handles.axes1);
            set(gcf, 'WindowButtonMotionFcn', @mouseMove);
            return
        end

        plot([floor(h(1,1)),floor(h(end,1))],[floor(h(1,2)),floor(h(end,2))],'-k');
        MasqueSel = Xpoly2maskX(h(:,1),h(:,2),LinS,ColS);


        % Extract the data... 

        [TheListY,TheListX] = find(MasqueSel == 1);    % in row / column format
        Ou = (round(TheListX)-1)*length(TheMap(:,1)) + round(TheListY);

        Compt = 0;
        
        
        % We select only the pixels with a 'valid' composition
        for i=1:length(Ou)
            if sum(Valeurs2Thermo(1).val(Ou(i),:))
                Compt = Compt+1;
                TheDataShorted(1).Compos(Compt,:) = Valeurs2Thermo(1).val(Ou(i),:);
            end
        end

        
        for iMin = 2:NbMin

            title(['Select an area in ',char(lesNamesMin{iMin}),'...'])

            % ON EST ICI
            h = [];
            clique = 1;
            ComptResult = 1;
            while clique < 2
                [a,b,clique] = ginput(1);          % here ginput because we are not in the GUI !!!
                if clique < 2
                    h(ComptResult,1) = a;
                    h(ComptResult,2) = b;
                    plot(floor(h(ComptResult,1)),floor(h(ComptResult,2)),'.w')
                    if ComptResult >= 2 % start
                        plot([floor(h(ComptResult-1,1)),floor(h(ComptResult,1))],[floor(h(ComptResult-1,2)),floor(h(ComptResult,2))],'-k')
                    end
                    ComptResult = ComptResult + 1;
                end
            end

            % Trois points minimum...
            if length(h(:,1)) < 3
                CodeTxt = [11,5];
                set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
                TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

                % set(handles.TxtControl,'String',[char(handles.TxtDatabase(11).txt(5))]);
                return
            end

            plot([floor(h(1,1)),floor(h(end,1))],[floor(h(1,2)),floor(h(end,2))],'-k');
            MasqueSel = Xpoly2maskX(h(:,1),h(:,2),LinS,ColS);


            % Extract the data... 
            [TheListY,TheListX] = find(MasqueSel == 1);   % in row / column format
            Ou = (round(TheListX)-1)*length(TheMap(:,1)) + round(TheListY);

            
            % We select only the pixels with a 'valid' composition
            Compt = 0;
            for i=1:length(Ou)
                if sum(Valeurs2Thermo(iMin).val(Ou(i),:))
                    Compt = Compt+1;
                    TheDataShorted(iMin).Compos(Compt,:) = Valeurs2Thermo(iMin).val(Ou(i),:);
                end
            end
            
            if iMin == NbMin % Alors on peut calculer...

                for i=1:NbMin
                    NbAna(i) = length(TheDataShorted(i).Compos(:,1));
                end

                LesCombi = AllCombi(NbAna);

                % First test to see the number of output variables (in
                % order to define the variable TheValeurs)
                i=1;
                for j=1:NbMin
                    CompoMin(j,:) = TheDataShorted(j).Compos(LesCombi(i,j),:); 
                end
                
                %set(gcf, 'WindowButtonMotionFcn', '');
                eval(Commande);
                %set(gcf, 'WindowButtonMotionFcn', @mouseMove);
                
                TheValeurs = zeros(length(LesCombi(:,1)),length(ListOutput));

                % Computation
                ComptWait = 0;
                h = waitbar(0,'Please wait...');
                
                for i=1:length(LesCombi(:,1))
                    for j=1:NbMin
                        CompoMin(j,:) = TheDataShorted(j).Compos(LesCombi(i,j),:); 
                    end
                    ComptWait = ComptWait + 1;
                    
                    if ComptWait > 2000
                        ComptWait = 0;
                        waitbar(i/length(LesCombi(:,1)),h);
                    end

                    %set(gcf, 'WindowButtonMotionFcn', '');
                    eval(Commande);     
                    %set(gcf, 'WindowButtonMotionFcn', @mouseMove);
                    
                    for j=1:length(ListOutput)
                        eval(['TheValeurs(i,j) = ',char(ListOutput{j}),';']);
                    end 

                end
                close(h);
                
                TextAffich0 = ['Results (Pairs: ',char(num2str(length(LesCombi(:,1)))),')'];
                TextAffich = '... ';
                for i=1:length(ListOutput)
                    LaMeanFin = mean(TheValeurs(:,i));
                    LaStdFin = std(TheValeurs(:,i));
                    if LaMeanFin > 5
                        TextAffich = [char(TextAffich),char(ListOutput{i}),' = ',int2str(LaMeanFin),' +/- ',int2str(LaStdFin),' (1o) ',' ... '];
                    else
                        TextAffich = [char(TextAffich),char(ListOutput{i}),' = ',num2str(LaMeanFin,3),' +/- ',num2str(LaStdFin,3),' (1o) ',' ... '];
                    end
                end  

                xlabel({TextAffich0,TextAffich});
                title('');
                
                figure
                histfit(TheValeurs(:,1),30)
                
                % Sauvegarde des resultats
                for i=1:NbMin
                    lesResults.test(ComptCouples).oxides(i,:) = mean(TheDataShorted(i).Compos(:,:),1);
                end
                
                lesResults.test(ComptCouples).first = TextAffich0;
                lesResults.test(ComptCouples).second = TextAffich;

            end

        end
        
    end

    if ComptCouples
        % On propose une sauvegarde
        
        [Success,Message,MessageID] = mkdir('Results');

        cd Results
            [Directory, pathname] = uiputfile({'*.txt', 'TXT Files (*.txt)'}, 'Export results as...');
        cd ..
        
        if Directory
            fid = fopen([char(pathname),char(Directory)],'w');
            fprintf(fid,'%s\n','Results from XMapTools');
            fprintf(fid,'%s\n',['Method: ',char(lesResults.method)]);
            fprintf(fid,'%s\n\n',['Minerals: ',char(lesResults.minerals)]);
            
            for i=1:length(lesResults.test)
                fprintf(fid,'%s\n',['* * * * * * * * Couple ',num2str(i),' * * * * * * * * ']);
                for iMin = 1:length(lesResults.test(i).oxides(:,1))
                    fprintf(fid,'%s\n',[char(lesNamesMin{iMin}),' composition: ',num2str(lesResults.test(i).oxides(iMin,:),5)]);
                end
                fprintf(fid,'%s\n\n',char(lesResults.test(i).second));
%                 fprintf(fid,'%s\n',[char(lesNamesMin{1}),' composition: ',num2str(lesResults.test(i).oxides(1,:))]);
%                 fprintf(fid,'%s\n',[char(lesNamesMin{2}),' composition: ',num2str(lesResults.test(i).oxides(2,:))]);
%                 fprintf(fid,'%s\n\n',['T (C) = ',num2str(lesResults.test(i).T),' with ln(Kd) = ',num2str(lesResults.test(i).Kd)]);
            end
            fclose(fid);
        end    
    end
    
    % fin ici, on n'envoie pas vers Results...
    % Note temporairement, il n'y a pas de sauvegarde Matlab, mais d'un
    % autre cote tout est dans le fichier .txt
    
    CodeTxt = [11,16];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    
    axes(handles.axes1);
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    XmapWaitBar(1,handles);
    return
end


if weAreType == 5
    axes(handles.axes1);
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    return
end


% ----------- Input -----------
Quanti = handles.quanti;
ValMin = get(handles.QUppmenu2,'Value');
LaQuanti = Quanti(ValMin);
    
ListInput = selectedFunction.input;

%ListInput = Thermometers.input;
ListAbsMap = []; % if we haven't maps.

Valeur2Therm = zeros(length(LaQuanti.elem(1).quanti(:)),length(ListInput));
ComptAbsMap = 0; % for elements without map. 

for iElem = 1:length(ListInput)
    LeElem = ListInput(iElem);

	[oui,ou] = ismember(LeElem,LaQuanti.listname); % map order
       
	% New test: have you this map ? (10/10)
	if oui
        DataElem = LaQuanti.elem(ou).quanti(:);
    else
        ComptAbsMap = ComptAbsMap+1;
        DataElem = zeros(length(LaQuanti.elem(1).quanti(:)),1);
        % En fait on cree une matrice de zeros sur la taille de
        % LaQuanti.elem(1) ou on est sur d'avoir une map. 
        ListAbsMap{ComptAbsMap} = LeElem;
    end
            
    for iNb = 1:length(DataElem)
    	Valeur2Therm(iNb,iElem) = DataElem(iNb);
    end
end 


% ----------- Warning -----------
if length(ListAbsMap) > 0
    % Some elements haven't maps...
    ListText = '';
    for i=1:length(ListAbsMap)
        ListText = strcat(ListText,char(ListAbsMap{i}),',');
    end
    
    TextIn = strcat('This thermometer uses elements: ',char(ListText),' for which data are not available. Continue ?');
    ButtonName = questdlg(TextIn,'Warning','Yes','No','Yes');
    if length(ButtonName) < 3
        CodeTxt = [14,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
        
        axes(handles.axes1);
        set(gcf, 'WindowButtonMotionFcn', @mouseMove);
        return % end of run
    end
end

% ----------- Calculation -----------
ListOutput = selectedFunction.output;
b = char(ListOutput);

for i=1:size(b,1) % rows
    for j=1:size(b,2) % columns
        if i == 1 & j == 1 
            Text = '[';
            Text = strcat(Text,b(i,j));
        elseif i ~= 1 & j == 1
            Text = strcat(Text,',',b(i,j));
        elseif j ~= 1
            Text = strcat(Text,b(i,j));
        end
    end
end

Text = strcat(Text,']');
Commande = char(strcat(Text,' = ',selectedFunction.file,'(Valeur2Therm,handles);'));


CodeTxt = [14,1];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),': ',char(selectedFunction.name),'']); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

% set(handles.TxtControl,'String',[char(handles.TxtDatabase(14).txt(1)),' - ',char(Thermometers.name),'']);

% New 2.1.3 (11.03.2015)
zoom off
handles.CorrectionMode = 1; 
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)

eval(Commande);

zoom on
handles.CorrectionMode = 0; 
guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)

% ----------- Extraction -----------
for i=1:length(Text) 
    if Text(i) == ','
        Text(i) = ';';
    end
end

eval(char(strcat('LesResultats = ',Text,';')));
LesResultats = LesResultats';

Results = handles.results;

% ----------- Save -----------
Icila = length(Results)+1;

%if Choice == 2 % points coord
%    Results(Icila).coord = [SelLinOk(:),SelColOk(:)];
%else
Results(Icila).coord = 0;
%end

Results(Icila).type = weAreType;
Results(Icila).mineral = externalFunctions(weAreType).minerals(minRef).name; %Thermometers.mineral;
Results(Icila).method = selectedFunction.name;
Results(Icila).labels = ListOutput;
Results(Icila).values = LesResultats;
Results(Icila).reshape = size(LaQuanti(1).elem(1).quanti);

handles.results = Results;

% ----------- Update -----------
ListTher(1) = {'none'};
for i=1:length(Results)
    ListTher(i+1) = Results(i).method;
end

Onest = length(ListTher);

set(handles.REppmenu1,'String',ListTher);
set(handles.REppmenu1,'Value',Onest);
set(handles.REppmenu2,'String',Results(Onest-1).labels);

guidata(hObject,handles);
AffOPT(3, hObject, eventdata, handles); % Maj 1.4.1

% ---------- Display ---------- 
REppmenu1_Callback(hObject, eventdata, handles)

GraphStyle(hObject, eventdata, handles)
axes(handles.axes1);
set(gcf, 'WindowButtonMotionFcn', @mouseMove);
XmapWaitBar(1,handles);
return


% #########################################################################
%       FUNCTION TO FIND ALL THE COMPO COMBINATIONS V1.6.4
function LesCombi = AllCombi(NbAna)
% This function compute all the combinations (vector) between different 
% list of index of compositions. NbAna is just a vector with the number of
% compositions of each mineral. 
%
% P. Lanari (2.08.13)

SystSize = length(NbAna);
Concat1 = '[';
Concat2 = '(';
Concat3 = '[';

for i=1:SystSize
    VariableName{i} = ['A',char(num2str(i))];
    eval([char(VariableName{i}),' = [1:NbAna(i)];']);
    
    Concat1 = [Concat1,'B',char(num2str(i)),','];
    Concat2 = [Concat2,char(VariableName{i}),','];
    
    Concat3 = [Concat3,'B',char(num2str(i)),'(:),'];
end

Concat1(end) = ']';
Concat2(end) = ')';
Concat3(end) = ']';

eval([Concat1,' = ndgrid',Concat2,';']);
eval(['LesCombi = ',Concat3,';']);    
return


% #########################################################################
%       RENAME RESULT V1.4.1
function REbutton1_Callback(hObject, eventdata, handles)
Results = handles.results;
Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none
    
if Onest
    CodeTxt = [14,2];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    % set(handles.TxtControl,'String',[char(handles.TxtDatabase(14).txt(2))]);

	Text = Results(Onest).method;
    Text = inputdlg({'new name'},'Name',1,Text);

    if ~length(Text)
        CodeTxt = [14,3];
        set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
        TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

        % set(handles.TxtControl,'String',[char(handles.TxtDatabase(14).txt(3))]);
        return
    end
    Results(Onest).method = Text;

    ListTher(1) = {'none'};
    for i=1:length(Results)
    	ListTher(i+1) = Results(i).method;
    end
	set(handles.REppmenu1,'String',ListTher);

	handles.results = Results;
    CodeTxt = [14,4];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' (',char(Text),')']); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

    %set(handles.TxtControl,'String',[char(handles.TxtDatabase(14).txt(4)),' (',char(Text),')']);
end
    
guidata(hObject,handles);
 

% #########################################################################
%       DELETE RESULT V1.4.1
function REbutton2_Callback(hObject, eventdata, handles)

Results = handles.results;


Onest = get(handles.REppmenu1,'Value') - 1;
if Onest < 1
    return
end

% ---------- Delete ---------- 
if Onest == 1
    for i=2:length(Results)
        NewResults(i-1) = Results(i);
    end
elseif Onest ==length(Results)
    for i=1:length(Results)-1
        NewResults(i) = Results(i);
    end
else
    for i=1:Onest-1
        NewResults(i) = Results(i);
    end
    for i=Onest+1:length(Results)
        NewResults(i-1) = Results(i);
    end
end 

handles.results = NewResults;

ListTher(1) = {'none'};
for i=1:length(NewResults)
	ListTher(i+1) = NewResults(i).method;
end

set(handles.REppmenu1,'String',ListTher) % New list
set(handles.REppmenu1,'Value',2) % Lastresult

% Display
REppmenu1_Callback(hObject, eventdata, handles);

guidata(hObject,handles);
return


% #########################################################################
%       EXPORT RESULTS V1.4.1
function REbutton3_Callback(hObject, eventdata, handles)
% the folder: Export-Not-Saved

Onest = get(handles.REppmenu1,'Value') - 1;
if Onest < 1
    return
end

Results = handles.results; % good location
LaListe = Results((Onest)).labels;
OnExporte = [1:length(LaListe)];

CodeTxt = [14,5];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

OnExporte = listdlg('ListString',LaListe,'SelectionMode','multiple','InitialValue',OnExporte,'Name','Data to export');

if ~length(OnExporte)
    CodeTxt = [14,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return
end

[Success,Message,MessageID] = mkdir('Exported-Results');

cd Exported-Results
[Directory, pathname] = uiputfile({'*.txt', 'TEXT File (*.txt)'}, 'Save results as');
cd ..

if ~Directory
    CodeTxt = [14,3];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    return    
end

disp(['Export ... (RESULTS in ascii format) ...']);
disp(['Export ... (mineral: ',char(Results(Onest).mineral),') ...']);
disp(['Esport ... (method: ',char(Results(Onest).method),') ...']);
disp(['Export ... (reshape: ',num2str(Results(Onest).reshape(1)),'/',num2str(Results(Onest).reshape(2)),') ...']);
    
Compt = 1;
for i=1:length(Results(Onest).labels)
    if Compt <= length(OnExporte)
        if i == OnExporte(Compt)
            ForSave = strcat(pathname,Directory(1:end-4),'-',Results(Onest).labels(i),'.txt');

            LesRes = Results(Onest).values(:,i);
            LesRes = reshape(LesRes,Results(Onest).reshape(1),Results(Onest).reshape(2));

            save(char(ForSave),'LesRes','-ASCII');
            disp(['Export ... (',char(Results(Onest).labels(i)),' was saved [',char(ForSave),']) ...'])
            Compt = Compt+1;
        else
            disp(['Export ... (',char(Results(Onest).labels(i)),' has not been saved ** User Request **) ...'])
        end
    else
        disp(['Export ... (',char(Results(Onest).labels(i)),' has not been saved ** User Request **) ...'])
    end
end

disp(['Export ... (RESULTS in ascii format) ... Ok']);

NbExported = length(OnExporte);

if NbExported == 1
    CodeTxt = [14,6];
    set(handles.TxtControl,'String',[char(num2str(NbExported)),char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
else
    CodeTxt = [14,7];
    set(handles.TxtControl,'String',[char(num2str(NbExported)),char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
end

return


% #########################################################################
%       FILTER RESULT V1.5.1
function REbutton4_Callback(hObject, eventdata, handles)
Results = handles.results;
% Median filter
set(handles.FIGbutton1,'Value',0);


SelResult = get(handles.REppmenu1,'Value') - 1;
SelAff = get(handles.REppmenu2,'Value');

SelMin = str2num(get(handles.FilterMin,'String'));
SelMax = str2num(get(handles.FilterMax,'String'));

Data4Filtre = Results(SelResult).values(:,SelAff); 

MaskSelected = zeros(length(Data4Filtre),1);
LesGood = find(Data4Filtre >= SelMin & Data4Filtre <= SelMax);
MaskSelected(LesGood) = ones(size(LesGood));

% Update
OuOk = length(Results)+1;
Results(OuOk) = Results(SelResult);
Results(OuOk).method = {[char(Results(OuOk).method),'_Filter']};


for i=1:length(Results(OuOk).values(1,:)) % ielem
    Results(OuOk).values(:,i) = Results(OuOk).values(:,i).*MaskSelected;
end

% add in the main list
ListTher(1) = {'none'};
for i=1:length(Results)
	ListTher(i+1) = Results(i).method;
end

set(handles.REppmenu1,'String',ListTher);
set(handles.REppmenu1,'Value',OuOk+1);

handles.results = Results;
guidata(hObject,handles);

REppmenu1_Callback(hObject, eventdata, handles);

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)
set(handles.axes1,'xtick',[], 'ytick',[]);
GraphStyle(hObject, eventdata, handles)
return


% #########################################################################
%       CHEM2D CALL v2.1.1
function REbutton5_Callback(hObject, eventdata, handles)
%

if get(handles.OPT1,'Value')

    MapsLabel = get(handles.PPMenu1,'String');
    MapsReshape = size(handles.data.map(get(handles.PPMenu1,'Value')).values);
    
    NbVar = length(MapsLabel);
    
    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    if get(handles.PPMenu2,'Value') > 1
        AllMask = handles.MaskFile(get(handles.PPMenu3,'Value')).Mask;
        TheMask = zeros(MapsReshape); 
        
        TheMask(find(AllMask == get(handles.PPMenu2,'Value')-1)) = ones(length(find(AllMask == get(handles.PPMenu2,'Value')-1)),1);
        
    else
        TheMask = ones(MapsReshape);
    end
    
    for i=1:NbVar
        Export(:,i) = handles.data.map(i).values(:).*TheMask(:).*BRCMask(:);
    end   
end

if get(handles.OPT2,'Value')

    MapsLabel = handles.quanti(get(handles.QUppmenu2,'Value')).listname;
    MapsReshape = size(handles.quanti(get(handles.QUppmenu2,'Value')).elem(get(handles.QUppmenu1,'Value')).quanti);
    
    NbVar = length(MapsLabel);
    
    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    for i=1:NbVar
        Export(:,i) = handles.quanti(get(handles.QUppmenu2,'Value')).elem(i).quanti(:).*BRCMask(:);
    end

end


if get(handles.OPT3,'Value')
    Results = handles.results;

    Onest = get(handles.REppmenu1,'Value') - 1;
    if Onest < 1
        warndlg('No result selected')
        return
    end

    MapsLabel = Results(Onest).labels;
    MapsReshape = Results(Onest).reshape;

    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    NbVar = length(Results(Onest).labels);
    for i = 1:NbVar
        Export(:,i) = Results(Onest).values(:,i).*BRCMask(:);
    end
    %Export = Results(Onest).values;
    

    
end


Seq = 'XMTMod2DTreatment(';
for i=1:NbVar
    Seq = strcat(Seq,'Export(:,',num2str(i),'),');
end
Seq = strcat(Seq,'MapsLabel,MapsReshape);');

eval(Seq);

return


% #########################################################################
%       TRIPLOT CALL V2.1.1
function REbutton6_Callback(hObject, eventdata, handles)
%
if get(handles.OPT1,'Value')

    MapsLabel = get(handles.PPMenu1,'String');
    MapsReshape = size(handles.data.map(get(handles.PPMenu1,'Value')).values);
    
    NbVar = length(MapsLabel);
    
    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    if get(handles.PPMenu2,'Value') > 1
        AllMask = handles.MaskFile(get(handles.PPMenu3,'Value')).Mask;
        TheMask = zeros(MapsReshape); 
        
        TheMask(find(AllMask == get(handles.PPMenu2,'Value')-1)) = ones(length(find(AllMask == get(handles.PPMenu2,'Value')-1)),1);
        
    else
        TheMask = ones(MapsReshape);
    end
    
    for i=1:NbVar
        Export(:,i) = handles.data.map(i).values(:).*TheMask(:).*BRCMask(:);
    end   
end

if get(handles.OPT2,'Value')

    MapsLabel = handles.quanti(get(handles.QUppmenu2,'Value')).listname;
    MapsReshape = size(handles.quanti(get(handles.QUppmenu2,'Value')).elem(get(handles.QUppmenu1,'Value')).quanti);
    
    NbVar = length(MapsLabel);
    
    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    for i=1:NbVar
        Export(:,i) = handles.quanti(get(handles.QUppmenu2,'Value')).elem(i).quanti(:).*BRCMask(:);
    end

end


if get(handles.OPT3,'Value')
    Results = handles.results;

    Onest = get(handles.REppmenu1,'Value') - 1;
    if Onest < 1
        warndlg('No result selected')
        return
    end

    MapsLabel = Results(Onest).labels;
    MapsReshape = Results(Onest).reshape;

    if get(handles.CorrButtonBRC,'Value')
        % there is a BRC correction available
        BRCMask = handles.corrections(1).mask;
    else
        BRCMask = ones(MapsReshape);
    end
    
    NbVar = length(Results(Onest).labels);
    for i = 1:NbVar
        Export(:,i) = Results(Onest).values(:,i).*BRCMask(:);
    end
    %Export = Results(Onest).values;

end

Seq = 'XMTModTriPlot(';
for i=1:NbVar
    Seq = strcat(Seq,'Export(:,',num2str(i),'),');
end
Seq = strcat(Seq,'MapsLabel,MapsReshape);');

eval(Seq);

%keyboard
% Results = handles.results;
% 
% Onest = get(handles.REppmenu1,'Value') - 1;
% if Onest < 1
%     warndlg('No result selected')
%     return
% end
% 
% 
% Export = Results(Onest).values;
% NbVar = length(Results(Onest).labels);
% 
% Seq = 'XMTModTriPlot(';
% 
% for i=1:NbVar
%     Seq = strcat(Seq,'Export(:,',num2str(i),'),');
% end
% 
% Seq = strcat(Seq,'Results(Onest).labels,Results(Onest).reshape);');
% 
% eval(Seq);

return



% #########################################################################
%       COMPUTE NEW VARIABLE FROM RESULT  V1.6.5
function REbutton7_Callback(hObject, eventdata, handles)
Results = handles.results;

SelResult = get(handles.REppmenu1,'Value') - 1;
SelAff = get(handles.REppmenu2,'Value');

ListAff = get(handles.REppmenu2,'String');

CodeTxt = [14,12];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

prompt={'<1> Enter the new variable name','<2> Enter the MATLAB code (using ./ and .* and .^)                    .'};
name='Create a new variable';
numlines=1;
defaultanswer={'XMg','Mg_M1./(Mg_M1+Fe_M1)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='none';
 
Theanswer=inputdlg(prompt,name,numlines,defaultanswer,options);

VarName = Theanswer{1};
ElCode4Display = Theanswer{2};

TheElement4DisplayClean = ElCode4Display;
TheLetters = isstrprop(TheElement4DisplayClean,'alpha')+isstrprop(TheElement4DisplayClean,'digit');   % alpha + digit

for i=1:length(TheElement4DisplayClean)
    if isequal(TheElement4DisplayClean(i),'_')         % _ is widely used in the names
        TheLetters(i) = 1;
    end
end

for i=1:length(TheLetters)
    if ~TheLetters(i)
        TheElement4DisplayClean(i) = ' ';
    end
end

TheElementsInCode = strread(TheElement4DisplayClean,'%s');

[Ok,Ou] = ismember(TheElementsInCode,ListAff);

% We change Ok for the Digits number which are not tested (see after). 
for i=1:length(Ok)
    if ~Ok(i)
        ThisOne = TheElementsInCode{i};
        TheDigits = isstrprop(ThisOne,'digit');
        
        if sum(TheDigits) == length(TheDigits)
            Ok(i) = 1;
        end
    end
end

if sum(Ok) ~= length(Ok)
    warndlg({'Element display Error. No corresponding map for the following elements:',char(TheElementsInCode{find(abs(Ok-1))})},'Warning');
    
    CodeTxt = [14,13];
    set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2)))]); 
    TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);
    
    return
end

set(gcf, 'WindowButtonMotionFcn', '');

% Prepare the element variables run ElCode4Display
for i = 1:length(ListAff)
    eval([char(ListAff{i}),' = reshape(Results(SelResult).values(:,i),Results(SelResult).reshape(1),Results(SelResult).reshape(2));']);
end

eval(['TheNewVariable = ',char(ElCode4Display),';']);

% We replace the NAN by 0
for i=1:length(TheNewVariable(:))
    if isnan(TheNewVariable(i))
        TheNewVariable(i) = 0;
    end
end

set(gcf, 'WindowButtonMotionFcn', @mouseMove);

% Update
Where = size(Results(SelResult).values,2) + 1;

Results(SelResult).values(:,Where) = TheNewVariable(:);
Results(SelResult).labels{Where} = VarName;

set(handles.REppmenu2,'String',Results(SelResult).labels);
set(handles.REppmenu2,'Value',Where);

handles.results = Results;
guidata(hObject,handles);


%REppmenu1_Callback(handles.REppmenu1, eventdata, handles);
% this doesn't work and I don't know why !!!
% The first variable is automatically selected. Impossible to change.

Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none$
if Onest == 0
    return
end
Onaff = get(handles.REppmenu2,'Value');

ListResult = get(handles.REppmenu1,'String');
ListDispl = get(handles.REppmenu2,'String');

CodeTxt = [3,3];
set(handles.TxtControl,'String',[char(handles.TxtDatabase(CodeTxt(1)).txt(CodeTxt(2))),' - ',char(ListResult(Onest+1)),' - ',char(ListDispl(Onaff))]); 
TxtColorControl_Callback(CodeTxt, hObject, eventdata, handles);

%set(handles.TxtControl,'String',[char(handles.TxtDatabase(3).txt(3)),' - ',char(ListResult(Onest+1)),' - ',char(ListDispl(Onaff))]);
    
AAfficher = reshape(Results(Onest).values(:,Onaff),Results(Onest).reshape(1),Results(Onest).reshape(2));

cla(handles.axes1,'reset');
axes(handles.axes1)
imagesc(XimrotateX(AAfficher,handles.rotateFig)), axis image, colorbar('vertical')
XMapColorbar(AAfficher,handles,1)
set(handles.axes1,'xtick',[], 'ytick',[]);

zoom on                                                         % New 1.6.2

handles.HistogramMode = 0;
handles.AutoContrastActiv = 0;
handles.MedianFilterActiv = 0;
%cla(handles.axes2);
%axes(handles.axes2), hist(AAfficher(find(AAfficher(:) ~= 0)),30)

Min = min(AAfficher(find(AAfficher(:) > 0)));
Max = max(AAfficher(:));
    
if length(Min) < 1
	Min = Max;
end
    
set(handles.ColorMin,'String',Min);
set(handles.ColorMax,'String',Max);
set(handles.FilterMin,'String',Min);
set(handles.FilterMax,'String',Max);

% Value = get(handles.checkbox1,'Value');

% Attention, les 4 lignes suivantes font des lags sur ma version.

axes(handles.axes1);
if Max > Min
	caxis([Min,Max]);
end

% if Value == 1
%     colormap([0,0,0;jet(64)])
% else
% 	colormap([jet(64)])
% end




guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles)
set(handles.axes1,'xtick',[], 'ytick',[]);
GraphStyle(hObject, eventdata, handles)
return



% #########################################################################
%       REMOVE A VARIABLE FROM RESULT  V1.6.5
function REbutton8_Callback(hObject, eventdata, handles)
Results = handles.results;

SelResult = get(handles.REppmenu1,'Value') - 1;
Vari2Remove = get(handles.REppmenu2,'Value');

NbVari = length(Results(SelResult).labels);

if isequal(Vari2Remove,1)
    Results(SelResult).values = Results(SelResult).values(:,2:end);
    Results(SelResult).labels = Results(SelResult).labels(2:end);
end

if isequal(Vari2Remove,NbVari)
    Results(SelResult).values = Results(SelResult).values(:,1:Vari2Remove-1);
    Results(SelResult).labels = Results(SelResult).labels(1:Vari2Remove-1);
end

if Vari2Remove > 1 && Vari2Remove < NbVari
    Results(SelResult).values = [Results(SelResult).values(:,1:Vari2Remove-1),Results(SelResult).values(:,Vari2Remove+1:end)];
    Results(SelResult).labels = [Results(SelResult).labels(1:Vari2Remove-1);Results(SelResult).labels(Vari2Remove+1:end)];
end


handles.results = Results;
guidata(hObject,handles);

REppmenu1_Callback(handles.REppmenu1, eventdata, handles);

guidata(hObject,handles);
OnEstOu(hObject, eventdata, handles);
set(handles.axes1,'xtick',[], 'ytick',[]);
GraphStyle(hObject, eventdata, handles);
return

% -------------------------------------------------------------------------
% 7) ADVANCED-USER FONCTIONS
% -------------------------------------------------------------------------


% #########################################################################
%       DEBUG MODE V1.4.1
function DebugMode_Callback(hObject, eventdata, handles)
%
% ButtonSettings_Callback(hObject, eventdata, handles)
% Not anymore used (I moved this button to the admin window)

disp(' ')
disp('- XMapTools [ADMIN] - ')
disp('Debug mode in the command windows')
disp('All variables are saved into the global variable handles')
disp('Use "return" to exit (handles variables will be updated');
disp(' ')


keyboard


guidata(hObject,handles);
return




% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%                           MATLAB-LIKE FUNCTIONS
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


% #########################################################################
%       IS FIELD RESULT (for loading function)  (V1.6.2)
function isFieldResult = myIsField (inStruct, fieldName)
% inStruct is the name of the structure or an array of structures to search
% fieldName is the name of the field for which the function searches
isFieldResult = 0;
f = fieldnames(inStruct(1));
for i=1:length(f)
    if(strcmp(f{i},strtrim(fieldName)))
        isFieldResult = 1;
        return;
    elseif isstruct(inStruct(1).(f{i}))
        isFieldResult = myIsField(inStruct(1).(f{i}), fieldName);
        if isFieldResult
            return;
        end
    end
end


% #########################################################################
%       XginputX function  (V1.6.2)
function [out1,out2,out3] = XginputX(arg1,handles)
%XginputX Graphical input from mouse for VER_XMapTools_750
%   [X,Y] = XGINPUT(N) gets N points from the current axes and returns 
%   the X- and Y-coordinates in the REF system (without rotate). 
%
%   P. Lanari (20.03.2013)

out1 = []; out2 = []; out3 = []; y = [];
c = computer;
if ~strcmp(c(1:2),'PC') 
   tp = get(0,'TerminalProtocol');
else
   tp = 'micro';
end

if ~strcmp(tp,'none') && ~strcmp(tp,'x') && ~strcmp(tp,'micro'),
   if nargout == 1,
      if nargin == 1,
         out1 = trmginput(arg1);
      else
         out1 = trmginput;
      end
   elseif nargout == 2 || nargout == 0,
      if nargin == 1,
         [out1,out2] = trmginput(arg1);
      else
         [out1,out2] = trmginput;
      end
      if  nargout == 0
         out1 = [ out1 out2 ];
      end
   elseif nargout == 3,
      if nargin == 1,
         [out1,out2,out3] = trmginput(arg1);
      else
         [out1,out2,out3] = trmginput;
      end
   end
else
   
   % Update Lanari (11:2012)
   %set(handles.TxtSelection,'String', 'selection on');
   %set(handles.TxtSelection,'ForegroundColor', [1 0 0]);

   fig = gcf;
   figure(gcf);
   
   
   if nargin == 0
      how_many = -1;
      b = [];
   else
      how_many = arg1;
      b = [];
      if  ischar(how_many) ...
            || size(how_many,1) ~= 1 || size(how_many,2) ~= 1 ...
            || ~(fix(how_many) == how_many) ...
            || how_many < 0
         error('MATLAB:ginput:NeedPositiveInt', 'Requires a positive integer.')
      end
      if how_many == 0
         ptr_fig = 0;
         while(ptr_fig ~= fig)
            ptr_fig = get(0,'PointerWindow');
         end
         scrn_pt = get(0,'PointerLocation');
         loc = get(fig,'Position');
         pt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
         out1 = pt(1); y = pt(2);
      elseif how_many < 0
         error('MATLAB:ginput:InvalidArgument', 'Argument must be a positive integer.')
      end
   end
 
   
   %keyboard
   
   
   % Suspend figure functions
   state = uisuspend(fig);
   
   
   % Display coordinates new 1.5.4 (11/2012)
   axes(handles.axes1);
   set(gcf, 'WindowButtonMotionFcn', @mouseMOVEginput);
   
   
   toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
   if ~isempty(toolbar)
        ptButtons = [uigettool(toolbar,'Plottools.PlottoolsOff'), ...
                     uigettool(toolbar,'Plottools.PlottoolsOn')];
        ptState = get (ptButtons,'Enable');
        set (ptButtons,'Enable','off');
   end

   %axes(handles.axes1);
   set(fig,'pointer','cross');
   fig_units = get(fig,'units');
   char = 0;

   % We need to pump the event queue on unix
   % before calling WAITFORBUTTONPRESS 
   drawnow

   
   while how_many ~= 0 
       
       % Use no-side effect WAITFORBUTTONPRESS
    waserr = 0;
      try
	keydown = wfbp;
      catch
	waserr = 1;
      end
      if(waserr == 1)
         if(ishghandle(fig))
            set(fig,'units',fig_units);
	    uirestore(state);
            error('MATLAB:ginput:Interrupted', 'Interrupted');
         else
            error('MATLAB:ginput:FigureDeletionPause', 'Interrupted by figure deletion');
         end
      end
        % g467403 - ginput failed to discern clicks/keypresses on the figure it was
        % registered to operate on and any other open figures whose handle
        % visibility were set to off
        figchildren = allchild(0);
        if ~isempty(figchildren)
            ptr_fig = figchildren(1);
        else
            error('MATLAB:ginput:FigureUnavailable','No figure available to process a mouse/key event'); 
        end
%         old code -> ptr_fig = get(0,'CurrentFigure'); Fails when the
%         clicked figure has handlevisibility set to callback
      
      if(ptr_fig == fig)
         if keydown
            char = get(fig, 'CurrentCharacter');
            button = abs(get(fig, 'CurrentCharacter'));
            scrn_pt = get(0, 'PointerLocation');
            set(fig,'units','pixels')
            loc = get(fig, 'Position');
            % We need to compensate for an off-by-one error:
            pt = [scrn_pt(1) - loc(1) + 1, scrn_pt(2) - loc(2) + 1];
            set(fig,'CurrentPoint',pt);
         else
            button = get(fig, 'SelectionType');
            if strcmp(button,'open') 
               button = 1;
            elseif strcmp(button,'normal') 
               button = 1;
            elseif strcmp(button,'extend')
               button = 2;
            elseif strcmp(button,'alt') 
               button = 3;
            else
               error('MATLAB:ginput:InvalidSelection', 'Invalid mouse selection.')
            end
         end
         pt = get(gca, 'CurrentPoint');
         
         how_many = how_many - 1;
         
         if(char == 13) % & how_many ~= 0)
            % if the return key was pressed, char will == 13,
            % and that's our signal to break out of here whether
            % or not we have collected all the requested data
            % points.  
            % If this was an early breakout, don't include
            % the <Return> key info in the return arrays.
            % We will no longer count it if it's the last input.
            break;
         end
         
         out1 = [out1;pt(1,1)];
         y = [y;pt(1,2)];
         b = [b;button];
      end
   end
   
   uirestore(state);
   if ~isempty(toolbar) && ~isempty(ptButtons)
        set (ptButtons(1),'Enable',ptState{1});
        set (ptButtons(2),'Enable',ptState{2});
   end
   set(fig,'units',fig_units);
   
   if nargout > 1
      out2 = y;
      if nargout > 2
         out3 = b;
      end
   else
      out1 = [out1 y];
   end
   
   
   % The folowing seems to work
  
   
   laSize = size(XimrotateX(handles.data.map(1).values,handles.rotateFig));

    lesX = [0 laSize(2)]; %get(handles.axes1,'XLim');
    lesY = [0 laSize(1)]; %get(handles.axes1,'YLim');

   xLength = lesX(2)-lesX(1);
   yLength = lesY(2)-lesY(1);

   
   switch handles.rotateFig
        
        case 0
            xFor = out1;
            yFor = out2;
            
            out1 = xFor;
            out2 = yFor;

            %set(handles.text47, 'string', round(C(1,1))); %abscisse
            %set(handles.text48, 'string', round(C(1,2))); %ordonnée
            
        case 90
            xFor = out1;
            yFor = out2;
            
            out1 = yLength - yFor;
            out2 = xFor;
            
            %set(handles.text47, 'string', round(yLength - C(1,2))); %abscisse
            %set(handles.text48, 'string', round(C(1,1))); %ordonnée
            
        case 180
            xFor = out1;
            yFor = out2;
            
            out1 = xLength - xFor;
            out2 = yLength - yFor;
            
            %set(handles.text47, 'string', round(xLength - C(1,1))); %abscisse
            %set(handles.text48, 'string', round(yLength - C(1,2))); %ordonnée
            
            
        case 270
            xFor = out1;
            yFor = out2;
            
            out1 = yFor;
            out2 = xLength - xFor;
            
            %set(handles.text47, 'string', round(C(1,2))); %abscisse
            %set(handles.text48, 'string', round(xLength - C(1,1))); %ordonnée   
   
   
   end
   
   % Update Lanari (11/12)
   %set(handles.TxtSelection,'String', 'selection off'); 
   %set(handles.TxtSelection,'ForegroundColor', [0 0 0]);
   
end

function mouseMOVEginput(hObject, eventdata)   % PL 11/2012

handles = guidata(hObject);

lesX = get(handles.axes1,'XLim');
lesY = get(handles.axes1,'YLim');

xLength = lesX(2)-lesX(1);
yLength = lesY(2)-lesY(1);

%set(gcf,'Units','characters');
C = get(gca,'CurrentPoint');%'CurrentPoint');  

if C(1,1) >= 0 && C(1,1) <= lesX(2) && C(1,2) >= 0 && C(1,2) <= lesY(2)
         
     
     switch handles.rotateFig
        
        case 0
            %set(gcf,'pointer','crosshair');
            set(handles.text47, 'string', round(C(1,1))); %abscisse
            set(handles.text48, 'string', round(C(1,2))); %ordonnée
            
        case 90
            %set(gcf,'pointer','crosshair');
            set(handles.text47, 'string', round(yLength - C(1,2))); %abscisse
            set(handles.text48, 'string', round(C(1,1))); %ordonnée
            
        case 180
            %set(gcf,'pointer','crosshair');
            set(handles.text47, 'string', round(xLength - C(1,1))); %abscisse
            set(handles.text48, 'string', round(yLength - C(1,2))); %ordonnée
            
            
        case 270
            %set(gcf,'pointer','crosshair');
            set(handles.text47, 'string', round(C(1,2))); %abscisse
            set(handles.text48, 'string', round(xLength - C(1,1))); %ordonnée   
  
    %set(handles.text47, 'string', round(C(1,1))); %abscisse
    %set(handles.text48, 'string', round(C(1,2))); %ordonnée  
    
     end
    
else
    
    set(handles.text47, 'string', '...'); %abscisse
    set(handles.text48, 'string', '...'); %ordonnée  
    
end

%set(gcf,'Units','characters');

return

function key = wfbp
%WFBP   Replacement for WAITFORBUTTONPRESS that has no side effects.

fig = gcf;
current_char = [];

% Now wait for that buttonpress, and check for error conditions
waserr = 0;
try
  h=findall(fig,'type','uimenu','accel','C');   % Disabling ^C for edit menu so the only ^C is for
  set(h,'accel','');                            % interrupting the function.
  keydown = waitforbuttonpress;
  current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
  if~isempty(current_char) && (keydown == 1)           % If the character was generated by the 
	  if(current_char == 3)                       % current keypress AND is ^C, set 'waserr'to 1
		  waserr = 1;                             % so that it errors out. 
	  end
  end
  
  set(h,'accel','C');                                 % Set back the accelerator for edit menu.
catch
  waserr = 1;
end
drawnow;
if(waserr == 1)
   set(h,'accel','C');                                % Set back the accelerator if it errored out.
   error('MATLAB:ginput:Interrupted', 'Interrupted');
end

if nargout>0, key = keydown; end



% #########################################################################
%       XkmeansX function  (V1.6.2)
function [idx, C, sumD, D] = XkmeansX(X, k, varargin)
%
% k-means for VER_XMapTools_750
% P. Lanari (Sept 2012)
% 
%
%

if nargin < 2
    error('At least two input arguments required.');
end

% n points in p dimensional space
[n, p] = size(X);
Xsort = []; Xord = [];

pnames = {   'distance'  'start' 'replicates' 'maxiter' 'emptyaction' 'display'};
dflts =  {'sqeuclidean' 'sample'          []       100        'error'  'notify'};
[errmsg,distance,start,reps,maxit,emptyact,display] ...
                       = statgetargs(pnames, dflts, varargin{:});
error(errmsg);

if ischar(distance)
    distNames = {'sqeuclidean','cityblock','cosine','correlation','hamming'};
    i = strmatch(lower(distance), distNames);
    if length(i) > 1
        error(sprintf('Ambiguous ''distance'' parameter value:  %s.', distance));
    elseif isempty(i)
        error(sprintf('Unknown ''distance'' parameter value:  %s.', distance));
    end
    distance = distNames{i};
    switch distance 
    case 'cityblock'
        [Xsort,Xord] = sort(X,1);
    case 'cosine'
        Xnorm = sqrt(sum(X.^2, 2));
        if any(min(Xnorm) <= eps * max(Xnorm))
            error(['Some points have small relative magnitudes, making them ', ...
                   'effectively zero.\nEither remove those points, or choose a ', ...
                   'distance other than ''cosine''.'], []);
        end
        X = X ./ Xnorm(:,ones(1,p));
    case 'correlation'
        X = X - repmat(mean(X,2),1,p);
        Xnorm = sqrt(sum(X.^2, 2));
        if any(min(Xnorm) <= eps * max(Xnorm))
            error(['Some points have small relative standard deviations, making them ', ...
                   'effectively constant.\nEither remove those points, or choose a ', ...
                   'distance other than ''correlation''.'], []);
        end
        X = X ./ Xnorm(:,ones(1,p));
    case 'hamming'
        if ~all(ismember(X(:),[0 1]))
            error('Non-binary data cannot be clustered using Hamming distance.');
        end
    end
else
    error('The ''distance'' parameter value must be a string.');
end

if ischar(start)
    startNames = {'uniform','sample','cluster'};
    i = strmatch(lower(start), startNames);
    if length(i) > 1
        error(sprintf('Ambiguous ''start'' parameter value:  %s.', start));
    elseif isempty(i)
        error(sprintf('Unknown ''start'' parameter value:  %s.', start));
    elseif isempty(k)
        error('You must specify the number of clusters, K.');
    end
    start = startNames{i};
    if strcmp(start, 'uniform')
        if strcmp(distance, 'hamming')
            error('Hamming distance cannot be initialized with uniform random values.');
        end
        Xmins = min(X,1);
        Xmaxs = max(X,1);
    end
elseif isnumeric(start)
    CC = start;
    start = 'numeric';
    if isempty(k)
        k = size(CC,1);
    elseif k ~= size(CC,1);
        error('The ''start'' matrix must have K rows.');
    elseif size(CC,2) ~= p
        error('The ''start'' matrix must have the same number of columns as X.');
    end
    if isempty(reps)
        reps = size(CC,3);
    elseif reps ~= size(CC,3);
        error('The third dimension of the ''start'' array must match the ''replicates'' parameter value.');
    end
    
    % Need to center explicit starting points for 'correlation'. (Re)normalization
    % for 'cosine'/'correlation' is done at each iteration.
    if isequal(distance, 'correlation')
        CC = CC - repmat(mean(CC,2),[1,p,1]);
    end
else
    error('The ''start'' parameter value must be a string or a numeric matrix or array.');
end

if ischar(emptyact)
    emptyactNames = {'error','drop','singleton'};
    i = strmatch(lower(emptyact), emptyactNames);
    if length(i) > 1
        error(sprintf('Ambiguous ''emptyaction'' parameter value:  %s.', emptyact));
    elseif isempty(i)
        error(sprintf('Unknown ''emptyaction'' parameter value:  %s.', emptyact));
    end
    emptyact = emptyactNames{i};
else
    error('The ''emptyaction'' parameter value must be a string.');
end

if ischar(display)
    i = strmatch(lower(display), strvcat('off','notify','final','iter'));
    if length(i) > 1
        error(sprintf('Ambiguous ''display'' parameter value:  %s.', display));
    elseif isempty(i)
        error(sprintf('Unknown ''display'' parameter value:  %s.', display));
    end
    display = i-1;
else
    error('The ''display'' parameter value must be a string.');
end

if k == 1
    error('The number of clusters must be greater than 1.');
elseif n < k
    error('X must have more rows than the number of clusters.');
end

% Assume one replicate
if isempty(reps)
    reps = 1;
end

%
% Done with input argument processing, begin clustering
%

dispfmt = '%6d\t%6d\t%8d\t%12g';
D = repmat(NaN,n,k);   % point-to-cluster distances
Del = repmat(NaN,n,k); % reassignment criterion
m = zeros(k,1);

totsumDBest = Inf;
for rep = 1:reps
    switch start
    case 'uniform'
        C = unifrnd(Xmins(ones(k,1),:), Xmaxs(ones(k,1),:));
        % For 'cosine' and 'correlation', these are uniform inside a subset
        % of the unit hypersphere.  Still need to center them for
        % 'correlation'.  (Re)normalization for 'cosine'/'correlation' is
        % done at each iteration.
        if isequal(distance, 'correlation')
            C = C - repmat(mean(C,2),1,p);
        end
    case 'sample'
        C = double(X(randsample(n,k),:)); % X may be logical
    case 'cluster'
        Xsubset = X(randsample(n,floor(.1*n)),:);
        [dum, C] = kmeans(Xsubset, k, varargin{:}, 'start','sample', 'replicates',1);
    case 'numeric'
        C = CC(:,:,rep);
    end    
    changed = 1:k; % everything is newly assigned
    idx = zeros(n,1);
    totsumD = Inf;
    
    if display > 2 % 'iter'
        disp(sprintf('  iter\t phase\t     num\t         sum'));
    end
    
    %
    % Begin phase one:  batch reassignments
    %
    
    converged = false;
    iter = 0;
    while true
        % Compute the distance from every point to each cluster centroid
        D(:,changed) = distfun(X, C(changed,:), distance, iter);
        
        % Compute the total sum of distances for the current configuration.
        % Can't do it first time through, there's no configuration yet.
        if iter > 0
            totsumD = sum(D((idx-1)*n + (1:n)'));
            % Test for a cycle: if objective is not decreased, back out
            % the last step and move on to the single update phase
            if prevtotsumD <= totsumD
                idx = previdx;
                [C(changed,:), m(changed)] = gcentroids(X, idx, changed, distance, Xsort, Xord);
                iter = iter - 1;
                break;
            end
            if display > 2 % 'iter'
                disp(sprintf(dispfmt,iter,1,length(moved),totsumD));
            end
            if iter >= maxit, break; end
        end

        % Determine closest cluster for each point and reassign points to clusters
        previdx = idx;
        prevtotsumD = totsumD;
        [d, nidx] = min(D, [], 2);

        if iter == 0
            % Every point moved, every cluster will need an update
            moved = 1:n;
            idx = nidx;
            changed = 1:k;
        else
            % Determine which points moved
            moved = find(nidx ~= previdx);
            if length(moved) > 0
                % Resolve ties in favor of not moving
                moved = moved(D((previdx(moved)-1)*n + moved) > d(moved));
            end
            if length(moved) == 0
                break;
            end
            idx(moved) = nidx(moved);

            % Find clusters that gained or lost members
            changed = unique([idx(moved); previdx(moved)])';
        end

        % Calculate the new cluster centroids and counts.
        [C(changed,:), m(changed)] = gcentroids(X, idx, changed, distance, Xsort, Xord);
        iter = iter + 1;
        
        % Deal with clusters that have just lost all their members
        empties = changed(m(changed) == 0);
        if ~isempty(empties)
            switch emptyact
            case 'error'
                error(sprintf('Empty cluster created at iteration %d.',iter));
            case 'drop'
                % Remove the empty cluster from any further processing
                D(:,empties) = NaN;
                changed = changed(m(changed) > 0);
                if display > 0
                    warning(sprintf('Empty cluster created at iteration %d.',iter));
                end
            case 'singleton'
                if display > 0
                    warning(sprintf('Empty cluster created at iteration %d.',iter));
                end
                
                for i = empties
                    % Find the point furthest away from its current cluster.
                    % Take that point out of its cluster and use it to create
                    % a new singleton cluster to replace the empty one.
                    [dlarge, lonely] = max(d);
                    from = idx(lonely); % taking from this cluster
                    C(i,:) = X(lonely,:);
                    m(i) = 1;
                    idx(lonely) = i;
                    d(lonely) = 0;
                    
                    % Update clusters from which points are taken
                    [C(from,:), m(from)] = gcentroids(X, idx, from, distance, Xsort, Xord);
                    changed = unique([changed from]);
                end
            end
        end
    end % phase one

    % Initialize some cluster information prior to phase two
    switch distance
    case 'cityblock'
        Xmid = zeros([k,p,2]);
        for i = 1:k
            if m(i) > 0
                % Separate out sorted coords for points in i'th cluster,
                % and save values above and below median, component-wise
                Xsorted = reshape(Xsort(idx(Xord)==i), m(i), p);
                nn = floor(.5*m(i));
                if mod(m(i),2) == 0
                    Xmid(i,:,1:2) = Xsorted([nn, nn+1],:)';
                elseif m(i) > 1
                    Xmid(i,:,1:2) = Xsorted([nn, nn+2],:)';
                else
                    Xmid(i,:,1:2) = Xsorted([1, 1],:)';
                end
            end
        end
    case 'hamming'
        Xsum = zeros(k,p);
        for i = 1:k
            if m(i) > 0
                % Sum coords for points in i'th cluster, component-wise
                Xsum(i,:) = sum(X(idx==i,:), 1);
            end
        end
    end
    
    %
    % Begin phase two:  single reassignments
    %
    changed = find(m' > 0);
    lastmoved = 0;
    nummoved = 0;
    iter1 = iter;
    while iter < maxit
        % Calculate distances to each cluster from each point, and the
        % potential change in total sum of errors for adding or removing
        % each point from each cluster.  Clusters that have not changed
        % membership need not be updated.
        %
        % Singleton clusters are a special case for the sum of dists
        % calculation.  Removing their only point is never best, so the
        % reassignment criterion had better guarantee that a singleton
        % point will stay in its own cluster.  Happily, we get
        % Del(i,idx(i)) == 0 automatically for them.
		switch distance
		case 'sqeuclidean'
            for i = changed
                mbrs = (idx == i);
                sgn = 1 - 2*mbrs; % -1 for members, 1 for nonmembers
                if m(i) == 1
                    sgn(mbrs) = 0; % prevent divide-by-zero for singleton mbrs
                end
                Del(:,i) = (m(i) ./ (m(i) + sgn)) .* sum((X - C(repmat(i,n,1),:)).^2, 2);
            end
        case 'cityblock'
            for i = changed
                if mod(m(i),2) == 0 % this will never catch singleton clusters
                    ldist = Xmid(repmat(i,n,1),:,1) - X;
                    rdist = X - Xmid(repmat(i,n,1),:,2);
                    mbrs = (idx == i);
                    sgn = repmat(1-2*mbrs, 1, p); % -1 for members, 1 for nonmembers
                    Del(:,i) = sum(max(0, max(sgn.*rdist, sgn.*ldist)), 2);
                else
                    Del(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2);
                end
            end
        case {'cosine','correlation'}
            % The points are normalized, centroids are not, so normalize them
            normC(changed) = sqrt(sum(C(changed,:).^2, 2));
            if any(normC < eps) % small relative to unit-length data points
                error(sprintf('Zero cluster centroid created at iteration %d.',iter));
            end
            % This can be done without a loop, but the loop saves memory allocations
            for i = changed
                XCi = X * C(i,:)';
                mbrs = (idx == i);
                sgn = 1 - 2*mbrs; % -1 for members, 1 for nonmembers
                Del(:,i) = 1 + sgn .*...
                      (m(i).*normC(i) - sqrt((m(i).*normC(i)).^2 + 2.*sgn.*m(i).*XCi + 1));
            end
        case 'hamming'
            for i = changed
                if mod(m(i),2) == 0 % this will never catch singleton clusters
                    % coords with an unequal number of 0s and 1s have a
                    % different contribution than coords with an equal
                    % number
                    unequal01 = find(2*Xsum(i,:) ~= m(i));
                    numequal01 = p - length(unequal01);
                    mbrs = (idx == i);
                    Di = abs(X(:,unequal01) - C(repmat(i,n,1),unequal01));
                    Del(:,i) = (sum(Di, 2) + mbrs*numequal01) / p;
                else
                    Del(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2) / p;
                end
            end
		end

        % Determine best possible move, if any, for each point.  Next we
        % will pick one from those that actually did move.
        previdx = idx;
        prevtotsumD = totsumD;
        [minDel, nidx] = min(Del, [], 2);
        moved = find(previdx ~= nidx);
        if length(moved) > 0
            % Resolve ties in favor of not moving
            moved = moved(Del((previdx(moved)-1)*n + moved) > minDel(moved));
        end
        if length(moved) == 0
            % Count an iteration if phase 2 did nothing at all, or if we're
            % in the middle of a pass through all the points
            if (iter - iter1) == 0 | nummoved > 0
                iter = iter + 1;
                if display > 2 % 'iter'
                    disp(sprintf(dispfmt,iter,2,nummoved,totsumD));
                end
            end
            converged = true;
            break;
        end
        
        % Pick the next move in cyclic order
        moved = mod(min(mod(moved - lastmoved - 1, n) + lastmoved), n) + 1;
        
        % If we've gone once through all the points, that's an iteration
        if moved <= lastmoved
            iter = iter + 1;
            if display > 2 % 'iter'
                disp(sprintf(dispfmt,iter,2,nummoved,totsumD));
            end
            if iter >= maxit, break; end
            nummoved = 0;
        end
        nummoved = nummoved + 1;
        lastmoved = moved;
        
        oidx = idx(moved);
        nidx = nidx(moved);
        totsumD = totsumD + Del(moved,nidx) - Del(moved,oidx);
        
        % Update the cluster index vector, and rhe old and new cluster
        % counts and centroids
        idx(moved) = nidx;
        m(nidx) = m(nidx) + 1;
        m(oidx) = m(oidx) - 1;
        switch distance
        case 'sqeuclidean'
            C(nidx,:) = C(nidx,:) + (X(moved,:) - C(nidx,:)) / m(nidx);
            C(oidx,:) = C(oidx,:) - (X(moved,:) - C(oidx,:)) / m(oidx);
        case 'cityblock'
            for i = [oidx nidx]
                % Separate out sorted coords for points in each cluster.
                % New centroid is the coord median, save values above and
                % below median.  All done component-wise.
                Xsorted = reshape(Xsort(idx(Xord)==i), m(i), p);
                nn = floor(.5*m(i));
                if mod(m(i),2) == 0
                    C(i,:) = .5 * (Xsorted(nn,:) + Xsorted(nn+1,:));
                    Xmid(i,:,1:2) = Xsorted([nn, nn+1],:)';
                else
                    C(i,:) = Xsorted(nn+1,:);
                    if m(i) > 1
                        Xmid(i,:,1:2) = Xsorted([nn, nn+2],:)';
                    else
                        Xmid(i,:,1:2) = Xsorted([1, 1],:)';
                    end
                end
            end
        case {'cosine','correlation'}
            C(nidx,:) = C(nidx,:) + (X(moved,:) - C(nidx,:)) / m(nidx);
            C(oidx,:) = C(oidx,:) - (X(moved,:) - C(oidx,:)) / m(oidx);
        case 'hamming'
            % Update summed coords for points in each cluster.  New
            % centroid is the coord median.  All done component-wise.
            Xsum(nidx,:) = Xsum(nidx,:) + X(moved,:);
            Xsum(oidx,:) = Xsum(oidx,:) - X(moved,:);
            C(nidx,:) = .5*sign(2*Xsum(nidx,:) - m(nidx)) + .5;
            C(oidx,:) = .5*sign(2*Xsum(oidx,:) - m(oidx)) + .5;
        end
        changed = sort([oidx nidx]);
    end % phase two
    
    if (~converged) & (display > 0)
        warning(sprintf('Failed to converge in %d iterations.', maxit));
    end

    % Calculate cluster-wise sums of distances
    nonempties = find(m(:)'>0);
    D(:,nonempties) = distfun(X, C(nonempties,:), distance, iter);
    d = D((idx-1)*n + (1:n)');
    sumD = zeros(k,1);
    for i = 1:k
        sumD(i) = sum(d(idx == i));
    end
    if display > 1 % 'final' or 'iter'
        disp(sprintf('%d iterations, total sum of distances = %g',iter,totsumD));
    end

    % Save the best solution so far
    if totsumD < totsumDBest
        totsumDBest = totsumD;
        idxBest = idx;
        Cbest = C;
        sumDBest = sumD;
        if nargout > 3
            Dbest = D;
        end
    end
end

% Return the best solution
idx = idxBest;
C = Cbest;
sumD = sumDBest;
if nargout > 3
    D = Dbest;
end

function D = distfun(X, C, dist, iter)
%DISTFUN Calculate point to cluster centroid distances.
[n,p] = size(X);
D = zeros(n,size(C,1));
clusts = 1:size(C,1);

switch dist
case 'sqeuclidean'
    for i = clusts
        D(:,i) = sum((X - C(repmat(i,n,1),:)).^2, 2);
    end
case 'cityblock'
    for i = clusts
        D(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2);
    end
case {'cosine','correlation'}
    % The points are normalized, centroids are not, so normalize them
    normC = sqrt(sum(C.^2, 2));
    if any(normC < eps) % small relative to unit-length data points
        error(sprintf('Zero cluster centroid created at iteration %d.',iter));
    end
    % This can be done without a loop, but the loop saves memory allocations
    for i = clusts
        D(:,i) = 1 - (X * C(i,:)') ./ normC(i);
    end
case 'hamming'
    for i = clusts
        D(:,i) = sum(abs(X - C(repmat(i,n,1),:)), 2) / p;
    end
end

function [centroids, counts] = gcentroids(X, index, clusts, dist, Xsort, Xord)
%GCENTROIDS Centroids and counts stratified by group.
[n,p] = size(X);
num = length(clusts);
centroids = repmat(NaN, [num p]);
counts = zeros(num,1);
for i = 1:num
    members = find(index == clusts(i));
    if length(members) > 0
        counts(i) = length(members);
        switch dist
        case 'sqeuclidean'
            centroids(i,:) = sum(X(members,:),1) / counts(i);
        case 'cityblock'
            % Separate out sorted coords for points in i'th cluster,
            % and use to compute a fast median, component-wise
            Xsorted = reshape(Xsort(index(Xord)==clusts(i)), counts(i), p);
            nn = floor(.5*counts(i));
            if mod(counts(i),2) == 0
                centroids(i,:) = .5 * (Xsorted(nn,:) + Xsorted(nn+1,:));
            else
                centroids(i,:) = Xsorted(nn+1,:);
            end
        case {'cosine','correlation'}
            centroids(i,:) = sum(X(members,:),1) / counts(i); % unnormalized
        case 'hamming'
            % Compute a fast median for binary data, component-wise
            centroids(i,:) = .5*sign(2*sum(X(members,:), 1) - counts(i)) + .5;
        end
    end
end

function [emsg,varargout]=statgetargs(pnames,dflts,varargin)
%STATGETARGS Process parameter name/value pairs for statistics functions
%   [EMSG,A,B,...]=STATGETARGS(PNAMES,DFLTS,'NAME1',VAL1,'NAME2',VAL2,...)
%   accepts a cell array PNAMES of valid parameter names, a cell array
%   DFLTS of default values for the parameters named in PNAMES, and
%   additional parameter name/value pairs.  Returns parameter values A,B,...
%   in the same order as the names in PNAMES.  Outputs corresponding to
%   entries in PNAMES that are not specified in the name/value pairs are
%   set to the corresponding value from DFLTS.  If nargout is equal to
%   length(PNAMES)+1, then unrecognized name/value pairs are an error.  If
%   nargout is equal to length(PNAMES)+2, then all unrecognized name/value
%   pairs are returned in a single cell array following any other outputs.
%
%   EMSG is empty if the arguments are valid, or the text of an error message
%   if an error occurs.  STATGETARGS does not actually throw any errors, but
%   rather returns an error message so that the caller may throw the error.
%   Outputs will be partially processed after an error occurs.
%
%   This utility is used by some Statistics Toolbox functions to process
%   name/value pair arguments.
%
%   Example:
%       pnames = {'color' 'linestyle', 'linewidth'}
%       dflts  = {    'r'         '_'          '1'}
%       varargin = {{'linew' 2 'nonesuch' [1 2 3] 'linestyle' ':'}
%       [emsg,c,ls,lw] = statgetargs(pnames,dflts,varargin{:})    % error
%       [emsg,c,ls,lw,ur] = statgetargs(pnames,dflts,varargin{:}) % ok

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/02/04 19:25:45 $ 

% We always create (nparams+1) outputs:
%    one for emsg
%    nparams varargs for values corresponding to names in pnames
% If they ask for one more (nargout == nparams+2), it's for unrecognized
% names/values

% Initialize some variables
emsg = '';
nparams = length(pnames);
varargout = dflts;
unrecog = {};
nargs = length(varargin);

% Must have name/value pairs
if mod(nargs,2)~=0
    emsg = sprintf('Wrong number of arguments.');
else
    % Process name/value pairs
    for j=1:2:nargs
        pname = varargin{j};
        if ~ischar(pname)
            emsg = sprintf('Parameter name must be text.');
            break;
        end
        i = strmatch(lower(pname),pnames);
        if isempty(i)
            % if they've asked to get back unrecognized names/values, add this
            % one to the list
            if nargout > nparams+1
                unrecog((end+1):(end+2)) = {varargin{j} varargin{j+1}};
                
                % otherwise, it's an error
            else
                emsg = sprintf('Invalid parameter name:  %s.',pname);
                break;
            end
        elseif length(i)>1
            emsg = sprintf('Ambiguous parameter name:  %s.',pname);
            break;
        else
            varargout{i} = varargin{j+1};
        end
    end
end

varargout{nparams+1} = unrecog;



% #########################################################################
%       Xpoly2maskX function  (V1.6.2)
function BW = Xpoly2maskX(x,y,M,N)
%POLY2MASK-like function for VER_XMAPTOOLS_750 that 
%   Convert region-of-interest polygon to mask.


%narginchk(4,4);

% This function narginchk to validate the number of arguments is not
% compatible with the old version of Matlab. 
% Removed 1.6.5 (We don't need to check this here). 


validateattributes(x,{'double'},{},mfilename,'X',1);
validateattributes(y,{'double'},{},mfilename,'Y',2);
if length(x) ~= length(y)
    error(message('images:poly2mask:vectorSizeMismatch'));
end
if isempty(x)
    BW = false(M,N);
    return;
end
validateattributes(x,{'double'},{'real','vector','finite'},mfilename,'X',1);
validateattributes(y,{'double'},{'real','vector','finite'},mfilename,'Y',2);
validateattributes(M,{'double'},{'real','integer','nonnegative'},mfilename,'M',3);
validateattributes(N,{'double'},{'real','integer','nonnegative'},mfilename,'N',4);

if (x(end) ~= x(1)) || (y(end) ~= y(1))
    x(end+1) = x(1);
    y(end+1) = y(1);
end

[xe,ye] = Xpoly2edgelistX(x,y);
BW = Xedgelist2maskX(M,N,xe,ye);

return

function [xe, ye] = Xpoly2edgelistX(x,y,scale)

if nargin < 3
    scale = 5;
end

% Scale and quantize (x,y) locations to the higher resolution grid.
x = round(scale*(x - 0.5) + 1);
y = round(scale*(y - 0.5) + 1);

num_segments = length(x) - 1;
x_segments = cell(num_segments,1);
y_segments = cell(num_segments,1);
for k = 1:num_segments
    [x_segments{k},y_segments{k}] = XintlineX(x(k),x(k+1),y(k),y(k+1));
end

% Concatenate segment vertices.
x = cat(1,x_segments{:});
y = cat(1,y_segments{:});

% Horizontal edges are located where the x-value changes.
d = diff(x);
edge_indices = find(d);
xe = x(edge_indices);

% Wherever the diff is negative, the x-coordinate should be x-1 instead of
% x.
shift = find(d(edge_indices) < 0);
xe(shift) = xe(shift) - 1;

% In order for the result to be the same no matter which direction we are
% tracing the polynomial, the y-value for a diagonal transition has to be
% biased the same way no matter what.  We'll always chooser the smaller
% y-value associated with diagonal transitions.
ye = min(y(edge_indices), y(edge_indices+1));


return

function BW = Xedgelist2maskX(M,N,xe,ye,scale)

if nargin < 5
    scale = 5;
end

shift = (scale - 1)/2;

% Scale x values, throwing away edgelist points that aren't on a pixel's
% center column. 
xe = (xe+shift)/5;
idx = xe == floor(xe);
xe = xe(idx);
ye = ye(idx);

% Scale y values.
ye = ceil((ye + shift)/scale);

% Throw away horizontal edges that are too far left, too far right, or below the image.
bad_indices = find((xe < 1) | (xe > N) | (ye > M));
xe(bad_indices) = [];
ye(bad_indices) = [];

% Treat horizontal edges above the top of the image as they are along the
% upper edge.
ye = max(1,ye);

% Insert the edge list locations into a sparse matrix, taking
% advantage of the accumulation behavior of the SPARSE function.
S = sparse(ye,xe,1,M,N);

% We reduce the memory consumption of edgelist2mask by processing only a
% group of columns at a time (g274577); this does not compromise speed.
BW = false(size(S));
numCols = size(S,2);
columnChunk = 50;
for k = 1:columnChunk:numCols
  firstColumn = k;
  lastColumn = min(k + columnChunk - 1, numCols);
  columns = full(S(:, firstColumn:lastColumn));
  BW(:, firstColumn:lastColumn) = parityscan(columns); 
end

function [BW] = parityscan(F)
% F is a two-dimensional matrix containing nonnegative integers

nR = size(F,1);
nC = size(F,2);

BW = false(nR,nC);

for c=1:nC    
    
    somme = 0;
    for r=1:nR
        somme = somme+F(r,c);
        if mod(somme,2) == 1
            
            BW(r,c) = 1;
        end
    end
    
    
    %if length(find(F(:,c))) > 0
    %    keyboard
    %end
    
end


return

function [x,y] = XintlineX(x1, x2, y1, y2)
dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case.
if ((dx == 0) && (dy == 0))
  x = x1;
  y = y1;
  return;
end

flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
  
if (flip)
  x = flipud(x);
  y = flipud(y);
end

return










% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%                            CREATE FONCTIONS 
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


% #########################################################################
%     MINERAL LIST FOR THERMOMETERS
function THppmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return


% #########################################################################
%     THERMOMETERS LIST
function THppmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return


% #########################################################################
%     COMPUTATION MODES LIST
function THppmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% #########################################################################
%     ELEMENT SELECTION FOR DISPLAY
function PPMenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%                             OTHERS FUNCTIONS
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



% --- Executes during object creation, after setting all properties.
function FIGtext1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FIGtext1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in REbutton4.
% function REbutton4_Callback(hObject, eventdata, handles)
% Results = handles.results;
% 
% Onest = get(handles.REppmenu1,'Value') - 1;
% Lamap = get(handles.REppmenu2,'Value');
% if Onest < 1
%     return
% end
% 
% LesRes = Results(Onest).values(:,Lamap);
% LesRes = reshape(LesRes,Results(Onest).reshape(1),Results(Onest).reshape(2));
% 
% Clique = 1;
% 
% while Clique <= 2
%     [X,Y,Clique] = XginputX(1);
%     X = round(X);
%     Y = round(Y);
%     set(handles.REtext1,'String',num2str(LesRes(Y,X),3));
%     axes(handles.axes1)
%     hold on, plot(X,Y,'+k')
% end
% 
% set(handles.axes1,'xtick',[], 'ytick',[]);
% GraphStyle(hObject, eventdata, handles)
% return


% --- Executes on button press in REbutton5.
% %     2D-TREATMENT BUTTON
% function REbutton5_Callback(hObject, eventdata, handles)
% Results = handles.results;
% 
% Onest = get(handles.REppmenu1,'Value') - 1;
% if Onest < 1
%     warndlg('No result selected')
%     return
% end
% 
% 
% Export = Results(Onest).values;
% NbVar = length(Results(Onest).labels);
% 
% Seq = 'XMTMod2DTreatment(';
% 
% for i=1:NbVar
%     Seq = strcat(Seq,'Export(:,',num2str(i),'),');
% end
% 
% Seq = strcat(Seq,'Results(Onest).labels,Results(Onest).reshape);');
% 
% eval(Seq);
% 
% return
% 








% --- Executes on selection change in OPT.
% Cette fonction n'est plus utilisée depuis la version 1.4.1
function OPT_Callback(hObject, eventdata, handles)
%AffPAN(hObject, eventdata, handles);
%guidata(hObject,handles);
return


% --- Executes during object creation, after setting all properties.
function OPT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PPMaskMeth.
function PPMaskMeth_Callback(hObject, eventdata, handles)
% hObject    handle to PPMaskMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PPMaskMeth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PPMaskMeth


% --- Executes during object creation, after setting all properties.
function PPMaskMeth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PPMaskMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function QUmethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QUmethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% UNUSED CREATING-FUNCTIONS : 


% --- Executes during object creation, after setting all properties.
function ColorMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return

function ColorMin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return

% --- Executes during object creation, after setting all properties.
function PPMenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% A SUPPRIMER PAR LA SUITE

% #########################################################################
%     OPEN THE MAP IN A NEW WINDOW V antérieure
 function MapWindow_Callback(hObject, eventdata, handles)
% ValueMedian = get(handles.FIGbutton1,'Value');
% 
% if ValueMedian == 1
%     MedianSize = str2num(get(handles.FIGtext1,'String'));
%     Onfaitquoi = handles.currentdisplay; % Input change
% 
%     if Onfaitquoi == 1 % for type 1 (Elem + Mask)
%         Data = handles.data;
%         MaskFile = handles.MaskFile;
% 
%         MaskSelected = get(handles.PPMenu3,'Value');
%         Selected = get(handles.PPMenu1,'Value');
%         Mineral = get(handles.PPMenu2,'Value');
%         Value = get(handles.checkbox1,'Value');
% 
%         if Mineral > 1
%             RefMin = Mineral - 1;
%             AAfficher = MaskFile(MaskSelected).Mask == RefMin;
%             AAfficher = Data.map(Selected).values .* AAfficher;
% 
%         else
%             AAfficher = Data.map(Selected).values;
%         end
% 
%         figure, imagesc(medfilt2(AAfficher,[MedianSize,MedianSize])), axis image, colorbar horizontal
%         set(gca,'xtick',[], 'ytick',[]); 
%         
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
%         
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     elseif Onfaitquoi == 2 % for type 2 (elem + Mask)
%         Quanti = handles.quanti;
% 
%         ValMin = get(handles.QUppmenu2,'Value');
%         AllMin = get(handles.QUppmenu2,'String');
%         SelMin = AllMin(ValMin);
%         if char(SelMin) == char('.')
%             warndlg('map not yet quantified','cancelation');
%             return
%         end
% 
%         ValOxi = get(handles.QUppmenu1,'Value');
% 
%         figure,
%         imagesc(medfilt2(Quanti(ValMin).elem(ValOxi).quanti,[MedianSize,MedianSize])),
%         axis image, colorbar horizontal
%         set(gca,'xtick',[], 'ytick',[]);
% 
%         Value = get(handles.checkbox1,'Value');
% 
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
%         
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     elseif Onfaitquoi == 3 % for type 3 (results) 
%         Results = handles.results;
% 
%         Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none$
%         Onaff = get(handles.REppmenu2,'Value'); % T, Aliv ... 
% 
%         AAfficher = reshape(Results(Onest).values(:,Onaff),Results(Onest).reshape(1),Results(Onest).reshape(2));
% 
%         figure,
%         imagesc(medfilt2(AAfficher,[MedianSize,MedianSize])), colorbar('horizontal'), axis image
%         set(gca,'xtick',[], 'ytick',[]);
%         
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
% 
%         Value = get(handles.checkbox1,'Value');
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     end
% else
%     Onfaitquoi = handles.currentdisplay; % Input change
% 
%     if Onfaitquoi == 1 % for type 1 (Elem + Mask)
%         Data = handles.data;
%         MaskFile = handles.MaskFile;
% 
%         MaskSelected = get(handles.PPMenu3,'Value');
%         Selected = get(handles.PPMenu1,'Value');
%         Mineral = get(handles.PPMenu2,'Value');
%         Value = get(handles.checkbox1,'Value');
% 
%         if Mineral > 1
%             RefMin = Mineral - 1;
%             AAfficher = MaskFile(MaskSelected).Mask == RefMin;
%             AAfficher = Data.map(Selected).values .* AAfficher;
% 
%         else
%             AAfficher = Data.map(Selected).values;
%         end
% 
%         figure, imagesc(AAfficher), axis image, colorbar horizontal
%         set(gca,'xtick',[], 'ytick',[]);
%         
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
%         
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     elseif Onfaitquoi == 2 % for type 2 (elem + Mask)
%         Quanti = handles.quanti;
% 
%         ValMin = get(handles.QUppmenu2,'Value');
%         AllMin = get(handles.QUppmenu2,'String');
%         SelMin = AllMin(ValMin);
%         if char(SelMin) == char('.')
%             warndlg('map not yet quantified','cancelation');
%             return
%         end
% 
%         ValOxi = get(handles.QUppmenu1,'Value');
% 
%         figure,
%         imagesc(Quanti(ValMin).elem(ValOxi).quanti),
%         axis image, colorbar horizontal
%         set(gca,'xtick',[], 'ytick',[]);
%         
%         Value = get(handles.checkbox1,'Value');
% 
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
%         
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     elseif Onfaitquoi == 3 % for type 3 (results) 
%         Results = handles.results;
% 
%         Onest = get(handles.REppmenu1,'Value') - 1; % 1 is none$
%         Onaff = get(handles.REppmenu2,'Value'); % T, Aliv ... 
% 
%         AAfficher = reshape(Results(Onest).values(:,Onaff),Results(Onest).reshape(1),Results(Onest).reshape(2));
% 
%         figure,
%         imagesc(AAfficher), colorbar('horizontal'), axis image
%         set(gca,'xtick',[], 'ytick',[]);
%         
%         Max = str2num(get(handles.ColorMax,'String'));
%         Min = str2num(get(handles.ColorMin,'String'));
% 
%         Value = get(handles.checkbox1,'Value');
%         if Max > Min
%             caxis([Min,Max]);
%         end
%         if Value == 1
%             colormap([0,0,0;jet(64)])
%         else
%             colormap([jet(64)])
%         end
% 
%     end
% end
% 
% guidata(hObject,handles);
return



function QUppmenu1_CreateFcn(hObject, eventdata, handles)
return
% --- Executes during object creation, after setting all properties.

    
    function QUppmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return

% --- Executes during object creation, after setting all properties.
function REppmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REppmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function REppmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REppmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MenXray3_Callback(hObject, eventdata, handles)
% hObject    handle to MenXray3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenQuanti2_Callback(hObject, eventdata, handles)
% hObject    handle to MenQuanti2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FilterMin_Callback(hObject, eventdata, handles)
% hObject    handle to FilterMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterMin as text
%        str2double(get(hObject,'String')) returns contents of FilterMin as a double


% --- Executes during object creation, after setting all properties.
function FilterMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterMax_Callback(hObject, eventdata, handles)
% hObject    handle to FilterMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterMax as text
%        str2double(get(hObject,'String')) returns contents of FilterMax as a double


% --- Executes during object creation, after setting all properties.
function FilterMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in THppmenu4.
function THppmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to THppmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns THppmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from THppmenu4


% --- Executes during object creation, after setting all properties.
function THppmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to THppmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PPMaskFrom.
function PPMaskFrom_Callback(hObject, eventdata, handles)
% hObject    handle to PPMaskFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PPMaskFrom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PPMaskFrom


% --- Executes during object creation, after setting all properties.
function PPMaskFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PPMaskFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function PopUpColormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUpColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




 


% --- Executes during object creation, after setting all properties.
function CorrPopUpMenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CorrPopUpMenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Creates and returns a handle to the GUI figure. 
function h1 = VER_XMapTools_750_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'text', 86, ...
    'pushbutton', 137, ...
    'uipanel', 82, ...
    'axes', 6, ...
    'popupmenu', 27, ...
    'radiobutton', 6, ...
    'edit', 8, ...
    'checkbox', 13, ...
    'togglebutton', 11, ...
    'uitoolbar', 2, ...
    'uipushtool', 5), ...
    'override', 1, ...
    'release', 13, ...
    'resize', 'simple', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', '/Users/pierrelanari/Geologie/XMapTools-Releases/XMapTools2.1.7/Program/VER_XMapTools_750.m', ...
    'lastFilename', '/Users/pierrelanari/Geologie/XMapTools-Releases/XMapTools2.1.7/VER_XMapTools_750.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','characters',...
'PaperUnits','centimeters',...
'CloseRequestFcn',@(hObject,eventdata)VER_XMapTools_750('figure1_CloseRequestFcn',hObject,eventdata,guidata(hObject)),...
'Color',[0.925490196078431 0.925490196078431 0.925490196078431],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'DockControls','off',...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','XMapTools V1.X.X',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',[20.98404194812 29.67743169791],...
'PaperType','A4',...
'Position',[103.333333333333 0.0833333333333333 197.5 57.4166666666667],...
'ToolBar','none',...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PAN2a';

h2 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','PAN2a',...
'Clipping','on',...
'Position',[0.0835443037974684 0.851959361393324 0.912236286919831 0.0856313497822931],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUppmenu2';

h3 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUppmenu2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.00462534690101758 0.551020408163265 0.120259019426457 0.36734693877551],...
'String','Standardized mineral',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('QUppmenu2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','QUppmenu2');

appdata = [];
appdata.lastValidTag = 'QUppmenu1';

h4 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUppmenu1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.131359851988899 0.474576271186441 0.0860314523589269 0.440677966101695],...
'String','Wt%',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('QUppmenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','QUppmenu1');

appdata = [];
appdata.lastValidTag = 'uipanel77';

h5 = uipanel(...
'Parent',h2,...
'Title',blanks(0),...
'Tag','uipanel77',...
'Clipping','on',...
'Position',[0.225716928769658 0.0847457627118644 0.00185013876040704 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton4';

h6 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0101757631822387 0.0816326530612245 0.0212765957446809 0.36734693877551],...
'String','Re',...
'Tag','QUbutton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton0';

h7 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton0_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0360777058279371 0.0816326530612245 0.0212765957446809 0.36734693877551],...
'String','De',...
'Tag','QUbutton0',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton2';

h8 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0971322849213691 0.0816326530612245 0.0212765957446809 0.36734693877551],...
'String','Ex',...
'Tag','QUbutton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton8';

h9 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton8_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.137835337650324 0.0816326530612245 0.0212765957446809 0.36734693877551],...
'String','Fi',...
'Tag','QUbutton8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton3';

h10 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.191489361702128 0.0816326530612245 0.0212765957446809 0.36734693877551],...
'String','Su',...
'Tag','QUbutton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text27';

h11 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontWeight','demi',...
'HorizontalAlignment','left',...
'Position',[0.235892691951897 0.491525423728813 0.101757631822387 0.389830508474576],...
'String','std analyses used:',...
'Style','text',...
'Tag','text27',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUtexte1';

h12 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'FontName','Times New Roman',...
'HorizontalAlignment','left',...
'Position',[0.323774283071231 0.613628502248357 0.0342275670675301 0.288135593220339],...
'String','Nb',...
'Style','text',...
'Tag','QUtexte1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel78';

h13 = uipanel(...
'Parent',h2,...
'Title',blanks(0),...
'Tag','uipanel78',...
'Clipping','on',...
'Position',[0.37372802960222 0.0847457627118644 0.00185013876040702 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton_TEST';

h14 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton_TEST_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.266419981498612 0.0816326530612245 0.0212765957446808 0.36734693877551],...
'String','Te',...
'Tag','QUbutton_TEST',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton11';

h15 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton11_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.2368177613321 0.0816326530612245 0.0212765957446808 0.36734693877551],...
'String','Pl',...
'Tag','QUbutton11',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'THppmenu3';

h16 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THppmenu3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'ForegroundColor',[0.0784313725490196 0.168627450980392 0.549019607843137],...
'Position',[0.382978723404255 0.542372881355932 0.130434782608696 0.372881355932203],...
'String',{  'Structural formulae'; 'P-T  / map mode'; 'P-T  / spot mode'; 'General functions'; 'XThermoTools' },...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('THppmenu3_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','THppmenu3');

appdata = [];
appdata.lastValidTag = 'THppmenu1';

h17 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THppmenu1_Callback',hObject,eventdata,guidata(hObject)),...
'FontAngle','oblique',...
'FontName','Times New Roman',...
'Position',[0.520814061054579 0.542372881355932 0.160037002775208 0.372881355932203],...
'String','Minerals',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('THppmenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','THppmenu1');

appdata = [];
appdata.lastValidTag = 'THppmenu2';

h18 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THppmenu2_Callback',hObject,eventdata,guidata(hObject)),...
'FontAngle','oblique',...
'FontName','Times New Roman',...
'Position',[0.520814061054579 0.0816326530612245 0.160962072155412 0.36734693877551],...
'String','Thermometers',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('THppmenu2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','THppmenu2');

appdata = [];
appdata.lastValidTag = 'text_XThermoTools';

h19 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'FontAngle','italic',...
'FontName','Times New Roman',...
'FontWeight','bold',...
'ForegroundColor',[0.847058823529412 0.16078431372549 0],...
'Position',[0.384828862164662 0.122448979591837 0.123959296947271 0.26530612244898],...
'String',{  'XThermoTools is unavailable'; blanks(0) },...
'Style','text',...
'UserData',[],...
'Tag','text_XThermoTools',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'THbutton3';

h20 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THbutton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.537465309898242 0.0612244897959184 0.0999074930619797 0.448979591836735],...
'String','XTHERMOTOOLS',...
'Tag','THbutton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'THbutton1';

h21 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THbutton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.383903792784459 0.0408163265306122 0.0703052728954672 0.448979591836735],...
'String','COMPUTE',...
'Tag','THbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'THbutton2';

h22 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THbutton2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.488436632747456 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','?',...
'Tag','THbutton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'THppmenu4';

h23 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('THppmenu4_Callback',hObject,eventdata,guidata(hObject)),...
'FontAngle','oblique',...
'FontName','Times New Roman',...
'Position',[0.521739130434783 0.542372881355932 0.138760407030527 0.372881355932203],...
'String','Maskfile',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('THppmenu4_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','THppmenu4');

appdata = [];
appdata.lastValidTag = 'uipanel79';

h24 = uipanel(...
'Parent',h2,...
'Title',blanks(0),...
'Tag','uipanel79',...
'Clipping','on',...
'Position',[0.691951896392231 0.0847457627118644 0.00185013876040707 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton5';

h25 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton5_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.704902867715079 0.542372881355932 0.0212765957446809 0.372881355932203],...
'String','Me',...
'Tag','QUbutton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MergeInterpBoundaries';

h26 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MergeInterpBoundaries_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.733580018501388 0.542372881355932 0.120259019426457 0.389830508474576],...
'String','Border interpolation',...
'Style','checkbox',...
'Tag','MergeInterpBoundaries',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton6';

h27 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton6_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.704902867715079 0.0408163265306122 0.0212765957446809 0.408163265306122],...
'String','Em',...
'Tag','QUbutton6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton7';

h28 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton7_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.734505087881592 0.0408163265306122 0.0212765957446809 0.408163265306122],...
'String','Ea',...
'Tag','QUbutton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUbutton9';

h29 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUbutton9_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.765032377428307 0.0408163265306122 0.0212765957446809 0.408163265306122],...
'String','Ep',...
'Tag','QUbutton9',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PAN1a';

h30 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','PAN1a',...
'Clipping','on',...
'Position',[0.0835443037974684 0.853410740203193 0.912236286919831 0.0856313497822931],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PPMenu1';

h31 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PPMenu1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.00740055504162812 0.469387755102041 0.108233117483811 0.448979591836735],...
'String','Xray map',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PPMenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'UserData',[],...
'Tag','PPMenu1');

appdata = [];
appdata.lastValidTag = 'PPMenu2';

h32 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PPMenu2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.127659574468085 0.474576271186441 0.123034227567068 0.440677966101695],...
'String','Minerals',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PPMenu2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','PPMenu2');

appdata = [];
appdata.lastValidTag = 'MButton1';

h33 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.00925069380203515 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Ad',...
'UserData',[],...
'Tag','MButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MButton2';

h34 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MButton2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.0351526364477336 0.102040816326531 0.0212765957446808 0.36734693877551],...
'String','De',...
'UserData',[],...
'Tag','MButton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel68';

h35 = uipanel(...
'Parent',h30,...
'Title',blanks(0),...
'Tag','uipanel68',...
'Clipping','on',...
'Position',[0.256244218316375 0.0847457627118644 0.00185013876040702 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MButton4';

h36 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MButton4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.061054579093432 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','%',...
'UserData',[],...
'Tag','MButton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MButton3';

h37 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MButton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.087881591119334 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','In',...
'UserData',[],...
'Tag','MButton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton2';

h38 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.132284921369103 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Di',...
'Tag','MaskButton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton5';

h39 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton5_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.44218316373728 0.102040816326531 0.0212765957446808 0.36734693877551],...
'String','De',...
'UserData',[],...
'Tag','MaskButton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton6';

h40 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton6_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.158186864014801 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Sa',...
'Tag','MaskButton6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton4';

h41 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.1840888066605 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Ex',...
'Tag','MaskButton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton3';

h42 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.209990749306198 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Re',...
'Tag','MaskButton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PPMaskMeth';

h43 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PPMaskMeth_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.264569842738205 0.457627118644068 0.159111933395005 0.457627118644068],...
'String','Mask computation method',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PPMaskMeth_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','PPMaskMeth');

appdata = [];
appdata.lastValidTag = 'PPMaskFrom';

h44 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PPMaskFrom_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.264569842738205 0.0204081632653061 0.0795559666975023 0.448979591836735],...
'String',{  'Selection'; 'File' },...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PPMaskFrom_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','PPMaskFrom');

appdata = [];
appdata.lastValidTag = 'MaskButton1';

h45 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.345975948196115 0.0612244897959184 0.0740055504162812 0.448979591836735],...
'String','CLASSIFY',...
'Tag','MaskButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel69';

h46 = uipanel(...
'Parent',h30,...
'Tag','uipanel69',...
'UserData',[],...
'Clipping','on',...
'Position',[0.428307123034228 0.0847457627118644 0.00185013876040702 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PPMenu3';

h47 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PPMenu3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.43663274745606 0.457627118644068 0.100832562442183 0.457627118644068],...
'String','Mask file',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PPMenu3_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','PPMenu3');

appdata = [];
appdata.lastValidTag = 'uipanel70';

h48 = uipanel(...
'Parent',h30,...
'Title',blanks(0),...
'Tag','uipanel70',...
'Clipping','on',...
'Position',[0.543015726179465 0.0847457627118644 0.00185013876040707 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'CorrButton1';

h49 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('CorrButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.55504162812211 0.0612244897959184 0.0703052728954672 0.448979591836735],...
'String','CORRECT',...
'Tag','CorrButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRAffichage1';

h50 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'FontName','Times New Roman',...
'HorizontalAlignment','left',...
'Position',[0.675300647548566 0.508474576271186 0.211840888066605 0.406779661016949],...
'String','no file selected',...
'Style','text',...
'UserData',[],...
'Tag','PRAffichage1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel71';

h51 = uipanel(...
'Parent',h30,...
'Title',blanks(0),...
'Tag','uipanel71',...
'Clipping','on',...
'Position',[0.669750231267346 0.0847457627118644 0.00185013876040707 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUButton1';

h52 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.901942645698427 0.0612244897959184 0.093432007400555 0.448979591836735],...
'String','STANDARDIZE',...
'Tag','QUButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'QUmethod';

h53 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('QUmethod_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.899167437557817 0.423728813559322 0.0999074930619797 0.491525423728814],...
'String','Std method',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('QUmethod_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','QUmethod');

appdata = [];
appdata.lastValidTag = 'PRButton1';

h54 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.680851063829787 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Lo',...
'UserData',[],...
'Tag','PRButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel72';

h55 = uipanel(...
'Parent',h30,...
'Title',blanks(0),...
'Tag','uipanel72',...
'Clipping','on',...
'Position',[0.892691951896394 0.0847457627118644 0.00185013876040707 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRButton5';

h56 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton5_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.706753006475486 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Co',...
'Tag','PRButton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRButton3';

h57 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.786308973172988 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Di',...
'Tag','PRButton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRButton4';

h58 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.862164662349676 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Hi',...
'Tag','PRButton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRButton6';

h59 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton6_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.810360777058279 0.0612244897959184 0.0499537465309898 0.448979591836735],...
'String','EDIT',...
'Tag','PRButton6',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton7';

h60 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton7_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.510638297872341 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Me',...
'UserData',[],...
'Tag','MaskButton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'CorrPopUpMenu1';

h61 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('CorrPopUpMenu1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.553191489361702 0.457627118644068 0.110083256244218 0.457627118644068],...
'String',{  'Select Correction'; '[BRC]  Border removing correction'; '[TRC]  TOPO-related correction'; '[MPC]  Map position correction tool'; '[SPC]   Standard position correction tool'; '[IDC]   Intensity drift correction' },...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('CorrPopUpMenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','CorrPopUpMenu1');

appdata = [];
appdata.lastValidTag = 'PRButton7';

h62 = uicontrol(...
'Parent',h30,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PRButton7_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.732654949121184 0.102040816326531 0.0212765957446809 0.36734693877551],...
'String','Ch',...
'Tag','PRButton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PAN3a';

h63 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','PAN3a',...
'Clipping','on',...
'Position',[0.0835443037974684 0.853410740203193 0.912236286919831 0.0856313497822931],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REppmenu1';

h64 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REppmenu1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.00647548566142461 0.457627118644068 0.151711378353377 0.440677966101695],...
'String','Resultats',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('REppmenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','REppmenu1');

appdata = [];
appdata.lastValidTag = 'REppmenu2';

h65 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REppmenu2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.16836262719704 0.525423728813559 0.108233117483811 0.372881355932203],...
'String','Afficher',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('REppmenu2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','REppmenu2');

appdata = [];
appdata.lastValidTag = 'REbutton1';

h66 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0120259019426457 0.0473884469041854 0.0212765957446809 0.372881355932203],...
'String','Re',...
'Tag','REbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton2';

h67 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0388529139685476 0.0473884469041854 0.0212765957446808 0.372881355932203],...
'String','De',...
'Tag','REbutton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton3';

h68 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.125809435707678 0.0473884469041854 0.0212765957446809 0.372881355932203],...
'String','Ex',...
'Tag','REbutton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel80';

h69 = uipanel(...
'Parent',h63,...
'Title',blanks(0),...
'Tag','uipanel80',...
'Clipping','on',...
'Position',[0.282146160962072 0.0677966101694915 0.00185013876040702 0.813559322033898],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton7';

h70 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton7_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.21831637372803 0.0473884469041854 0.0212765957446809 0.372881355932203],...
'String','V+',...
'Tag','REbutton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton8';

h71 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton8_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.246993524514339 0.0473884469041854 0.0212765957446808 0.372881355932203],...
'String','V-',...
'Tag','REbutton8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'FilterMin';

h72 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('FilterMin_Callback',hObject,eventdata,guidata(hObject)),...
'Enable','off',...
'FontName','Times New Roman',...
'FontSize',9,...
'Position',[0.293246993524514 0.542372881355932 0.0573543015726179 0.372881355932203],...
'String','Min',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('FilterMin_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','FilterMin');

appdata = [];
appdata.lastValidTag = 'FilterMax';

h73 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('FilterMax_Callback',hObject,eventdata,guidata(hObject)),...
'Enable','off',...
'FontName','Times New Roman',...
'FontSize',9,...
'Position',[0.349676225716929 0.542372881355932 0.0573543015726179 0.372881355932203],...
'String','Max',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('FilterMax_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','FilterMax');

appdata = [];
appdata.lastValidTag = 'REbutton4';

h74 = uicontrol(...
'Parent',h63,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.304347826086957 0.0269802836388793 0.089731729879741 0.440677966101695],...
'String','APPLY FILTER',...
'Tag','REbutton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'TxtControl';

h75 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'FontName','Times New Roman',...
'FontSize',13,...
'FontWeight','demi',...
'ForegroundColor',[0 0 1],...
'Position',[0.159493670886076 0.00870827285921625 0.575527426160338 0.0435413642960813],...
'String',blanks(0),...
'Style','text',...
'Tag','TxtControl',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel61';

h76 = uipanel(...
'Parent',h1,...
'FontName','Times New Roman',...
'Title',blanks(0),...
'Tag','uipanel61',...
'Clipping','on',...
'Position',[-0.000843881856540084 0.939042089985486 1 0.003],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'title1';

h77 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',27,...
'FontWeight','bold',...
'ForegroundColor',[0.0784313725490196 0.168627450980392 0.549019607843137],...
'Position',[-0.000843881856540084 0.944847605224964 0.185654008438819 0.053701015965167],...
'String','XMapTools',...
'Style','text',...
'Tag','title1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel63';

h78 = uipanel(...
'Parent',h1,...
'Title',blanks(0),...
'Tag','uipanel63',...
'Clipping','on',...
'Position',[0.083 0.850507982583454 0.916 0.003],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AboutXMapTools';

h79 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('AboutXMapTools_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.532489451476793 0.956458635703919 0.019409282700422 0.0319303338171263],...
'String','Ab',...
'UserData',[],...
'Tag','AboutXMapTools',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'TextProjet';

h80 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'FontName','Times New Roman',...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[0.352742616033755 0.959361393323657 0.124050632911392 0.0261248185776488],...
'String','not saved',...
'Style','text',...
'Tag','TextProjet',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Button2';

h81 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('Button2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.19831223628692 0.956458635703919 0.0194092827004219 0.0319303338171263],...
'String','O',...
'Tag','Button2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Button3';

h82 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('Button3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.224472573839662 0.956458635703919 0.0194092827004219 0.0319303338171263],...
'String','S',...
'Tag','Button3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Button5';

h83 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('Button5_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.250632911392405 0.956458635703919 0.019409282700422 0.0319303338171263],...
'String','Sa',...
'Tag','Button5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Button1';

h84 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('Button1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.290295358649789 0.956458635703919 0.019409282700422 0.0319303338171263],...
'String','N',...
'Tag','Button1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Button4';

h85 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('Button4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.315611814345992 0.956458635703919 0.0194092827004219 0.0319303338171263],...
'String','E',...
'Tag','Button4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ExportWindow';

h86 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ExportWindow_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0320675105485232 0.811320754716981 0.0194092827004219 0.0319303338171263],...
'String','Ex',...
'Tag','ExportWindow',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'RotateButton';

h87 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('RotateButton_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0556962025316456 0.811320754716981 0.0194092827004219 0.0319303338171263],...
'String','Ro',...
'Tag','RotateButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ColorButton1';

h88 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ColorButton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.00928270042194093 0.811320754716981 0.0194092827004219 0.0319303338171263],...
'String','AC',...
'UserData',[],...
'Tag','ColorButton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ColorMin';

h89 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ColorMin_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',8,...
'Position',[0.00590717299578059 0.770682148040638 0.0362869198312236 0.0333817126269956],...
'String','Min',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('ColorMin_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','ColorMin');

appdata = [];
appdata.lastValidTag = 'ColorMax';

h90 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ColorMax_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',8,...
'Position',[0.0405063291139241 0.770682148040638 0.0362869198312236 0.0333817126269956],...
'String','Max',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('ColorMax_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','ColorMax');

appdata = [];
appdata.lastValidTag = 'text47';

h91 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'FontName','Times New Roman',...
'HorizontalAlignment','left',...
'Position',[0.0253164556962025 0.910014513788099 0.0489451476793249 0.0246734397677794],...
'String','...',...
'Style','text',...
'Tag','text47',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text48';

h92 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'FontName','Times New Roman',...
'HorizontalAlignment','left',...
'Position',[0.0253164556962025 0.8875 0.0506329113924051 0.0246734397677794],...
'String','...',...
'Style','text',...
'Tag','text48',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text73';

h93 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'HorizontalAlignment','right',...
'Position',[0.00253164556962025 0.912917271407837 0.0185654008438819 0.025],...
'String','x: ',...
'Style','text',...
'UserData',[],...
'Tag','text73',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text74';

h94 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'HorizontalAlignment','right',...
'Position',[0.00253164556962025 0.889695210449927 0.0185654008438819 0.025],...
'String','y: ',...
'Style','text',...
'UserData',[],...
'Tag','text74',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text75';

h95 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'ForegroundColor',[1 0 0],...
'HorizontalAlignment','right',...
'Position',[0.00253164556962025 0.866473149492017 0.0185654008438819 0.025],...
'String','z: ',...
'Style','text',...
'UserData',[],...
'Tag','text75',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text76';

h96 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'FontName','Times New Roman',...
'ForegroundColor',[1 0 0],...
'HorizontalAlignment','left',...
'Position',[0.0253164556962025 0.865 0.0489451476793249 0.0246734397677794],...
'String','...',...
'Style','text',...
'UserData',[],...
'Tag','text76',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'checkbox1';

h97 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('checkbox1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'Position',[0.00675105485232068 0.732946298984035 0.0244725738396624 0.0333817126269956],...
'String',blanks(0),...
'Style','checkbox',...
'Value',1,...
'Tag','checkbox1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'checkbox7';

h98 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('checkbox7_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',9,...
'Position',[0.0590717299578059 0.732946298984035 0.020253164556962 0.0333817126269956],...
'String',blanks(0),...
'Style','checkbox',...
'Tag','checkbox7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text77';

h99 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',9,...
'Position',[0.0236286919831224 0.737300435413643 0.0337552742616034 0.0217706821480407],...
'String','black',...
'Style','text',...
'UserData',[],...
'Tag','text77',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'FIGtext1';

h100 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('FIGtext1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',8,...
'Position',[0.0337552742616034 0.695210449927431 0.0362869198312236 0.0333817126269956],...
'String','2',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('FIGtext1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','FIGtext1');

appdata = [];
appdata.lastValidTag = 'FIGbutton1';

h101 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('FIGbutton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'Position',[0.00928270042194093 0.695210449927431 0.0194092827004219 0.0319303338171263],...
'String','MF',...
'Tag','FIGbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonWindowSize';

h102 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonWindowSize_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.972151898734177 0.957910014513788 0.019409282700422 0.0319303338171263],...
'String','WZ',...
'Tag','ButtonWindowSize',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonFigureMode';

h103 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonFigureMode_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.918987341772152 0.957910014513788 0.019409282700422 0.0319303338171263],...
'String','FM',...
'Tag','ButtonFigureMode',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'BUsampling2';

h104 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('BUsampling2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.00843881856540084 0.602322206095791 0.0194092827004219 0.0319303338171263],...
'String','SL',...
'Tag','BUsampling2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text79';

h105 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.00843881856540084 0.641509433962264 0.0658227848101266 0.02322206095791],...
'String','Sampling',...
'Style','text',...
'UserData',[],...
'Tag','text79',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'BUsampling3';

h106 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('BUsampling3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0312236286919831 0.602322206095791 0.0194092827004219 0.0319303338171263],...
'String','SA',...
'Tag','BUsampling3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'SamplingDisplay';

h107 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Enable','inactive',...
'FontName','Times New Roman',...
'FontSize',9,...
'Position',[0.00675105485232068 0.564586357039187 0.0675105485232068 0.0333817126269956],...
'String',blanks(0),...
'Style','edit',...
'UserData',[],...
'Tag','SamplingDisplay',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'OPT3';

h108 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('OPT3_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'FontWeight','bold',...
'Position',[0.787341772151899 0.957910014513788 0.070042194092827 0.029],...
'String','Results',...
'Style','togglebutton',...
'UserData',[],...
'Tag','OPT3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'OPT2';

h109 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('OPT2_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'FontWeight','bold',...
'Position',[0.705485232067511 0.957910014513788 0.070042194092827 0.029],...
'String','Quanti',...
'Style','togglebutton',...
'UserData',[],...
'Tag','OPT2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'OPT1';

h110 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('OPT1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'FontWeight','bold',...
'Position',[0.624472573839662 0.957910014513788 0.070042194092827 0.029],...
'String','Xray',...
'Style','togglebutton',...
'UserData',[],...
'Tag','OPT1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton5';

h111 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton5_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'FontWeight','bold',...
'Position',[0.00675105485232068 0.474600870827286 0.070042194092827 0.0333817126269957],...
'String','Chem2D',...
'Tag','REbutton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel60';

h112 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','uipanel60',...
'Clipping','on',...
'Position',[0.1389 0.0914 0.8547 0.7402],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'axes2';

h113 = axes(...
'Parent',h112,...
'Position',[0.0870712401055409 0.0725490196078429 0.829815303430076 0.443137254901961],...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'FontName','Times New Roman',...
'LooseInset',[0.392695629329581 0.488970218210436 0.286969882971616 0.333388785143479],...
'XColor',get(0,'defaultaxesXColor'),...
'YColor',get(0,'defaultaxesYColor'),...
'ZColor',get(0,'defaultaxesZColor'),...
'Tag','axes2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h114 = get(h113,'title');

set(h114,...
'Parent',h113,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499404761904762 1.01991150442478 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h115 = get(h113,'xlabel');

set(h115,...
'Parent',h113,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499404761904762 -0.0862831858407076 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','top',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h116 = get(h113,'ylabel');

set(h116,...
'Parent',h113,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[-0.0267857142857142 0.493362831858407 1.00005459937205],...
'Rotation',90,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h117 = get(h113,'zlabel');

set(h117,...
'Parent',h113,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0.15 0.15 0.15],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Times New Roman',...
'FontSize',11,...
'FontWeight','normal',...
'HorizontalAlignment','left',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',3,...
'Position',[-0.301785714285714 2.59955752212389 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','middle',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

appdata = [];
appdata.lastValidTag = 'axes3';

h118 = axes(...
'Parent',h112,...
'Position',[0.0857519788918204 0.580392156862743 0.829815303430076 0.372549019607843],...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'FontName','Times New Roman',...
'LooseInset',[0.472531230774517 0.525479323071668 0.345311284027531 0.358281356639774],...
'XColor',get(0,'defaultaxesXColor'),...
'YColor',get(0,'defaultaxesYColor'),...
'ZColor',get(0,'defaultaxesZColor'),...
'Tag','axes3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h119 = get(h118,'title');

set(h119,...
'Parent',h118,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499404761904762 1.02368421052632 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h120 = get(h118,'xlabel');

set(h120,...
'Parent',h118,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499404761904762 -0.102631578947369 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','top',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h121 = get(h118,'ylabel');

set(h121,...
'Parent',h118,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[-0.0267857142857143 0.492105263157895 1.00005459937205],...
'Rotation',90,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h122 = get(h118,'zlabel');

set(h122,...
'Parent',h118,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0.15 0.15 0.15],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Times New Roman',...
'FontSize',11,...
'FontWeight','normal',...
'HorizontalAlignment','left',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',3,...
'Position',[-0.300595238095238 1.72894736842105 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','middle',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

appdata = [];
appdata.lastValidTag = 'uipanel59';

h123 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','uipanel59',...
'Clipping','on',...
'Position',[0.1389 0.0914 0.8547 0.7402],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'axes1';

h124 = axes(...
'Parent',h123,...
'Position',[0.00592300098716681 0.0490196078431373 0.915103652517275 0.911764705882353],...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'FontName','Times New Roman',...
'LooseInset',[0.324626248755178 0.356461008962395 0.237226874090323 0.243041597019815],...
'XColor',get(0,'defaultaxesXColor'),...
'XLim',get(0,'defaultaxesXLim'),...
'XLimMode','manual',...
'XTickLabel',{  blanks(0); '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
'XTickLabelMode','manual',...
'YColor',get(0,'defaultaxesYColor'),...
'YTickLabel',{  blanks(0); '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
'YTickLabelMode','manual',...
'ZColor',get(0,'defaultaxesZColor'),...
'Tag','axes1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h125 = get(h124,'title');

set(h125,...
'Parent',h124,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499460043196544 1.00967741935484 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h126 = get(h124,'xlabel');

set(h126,...
'Parent',h124,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[0.499460043196544 -0.0419354838709678 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','top',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h127 = get(h124,'ylabel');

set(h127,...
'Parent',h124,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',2,...
'Position',[-0.0242980561555076 0.497849462365591 1.00005459937205],...
'Rotation',90,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','on',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

h128 = get(h124,'zlabel');

set(h128,...
'Parent',h124,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0.15 0.15 0.15],...
'DisplayName',blanks(0),...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Times New Roman',...
'FontSize',11,...
'FontWeight','normal',...
'HorizontalAlignment','left',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',3,...
'Position',[-0.185205183585313 1.28924731182796 1.00005459937205],...
'Rotation',0,...
'String',blanks(0),...
'Interpreter','tex',...
'VerticalAlignment','middle',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag',blanks(0),...
'UserData',[],...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'IncludeRenderer','on',...
'Clipping','off');

appdata = [];
appdata.lastValidTag = 'uipanel62';

h129 = uipanel(...
'Parent',h1,...
'Tag','uipanel62',...
'UserData',[],...
'Clipping','on',...
'Position',[0.083 -0.00145137880986938 0.002 0.943],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'UiPanelScrollBar';

h130 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'Title',blanks(0),...
'Tag','UiPanelScrollBar',...
'Clipping','on',...
'Position',[0.739240506329114 0.00435413642960813 0.254008438818565 0.0638606676342525],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'WaitBar1';

h131 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'BackgroundColor',[0 0 0],...
'Position',[0.026578073089701 0.26 0.770764119601329 0.36],...
'String',blanks(0),...
'Style','text',...
'Tag','WaitBar1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'WaitBar2';

h132 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Position',[0.0431893687707641 0.340909090909091 0.737541528239203 0.181818181818182],...
'String',blanks(0),...
'Style','text',...
'Tag','WaitBar2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DispWait';

h133 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'BackgroundColor',[0.972549019607843 0.972549019607843 0.972549019607843],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('DispWait_Callback',hObject,eventdata,guidata(hObject)),...
'Enable','inactive',...
'Position',[0.817275747508306 0 0.132890365448505 0.886363636363636],...
'String',blanks(0),...
'Tag','DispWait',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text61';

h134 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'Position',[0.794019933554817 0.75 0.172757475083056 0.181818181818182],...
'String',blanks(0),...
'Style','text',...
'Tag','text61',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text62';

h135 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'Position',[0.794019933554817 0 0.172757475083056 0.227272727272727],...
'String',blanks(0),...
'Style','text',...
'Tag','text62',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text63';

h136 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'Position',[0.933554817275748 0.204545454545455 0.0265780730897009 0.545454545454545],...
'String',blanks(0),...
'Style','text',...
'Tag','text63',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text64';

h137 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'Position',[0.81063122923588 0.204545454545455 0.0265780730897009 0.545454545454545],...
'String',blanks(0),...
'Style','text',...
'Tag','text64',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'WaitBar3';

h138 = uicontrol(...
'Parent',h130,...
'Units','normalized',...
'BackgroundColor',[0.847058823529412 0.16078431372549 0],...
'Position',[0.0365448504983389 0.340909090909091 0.0564784053156146 0.181818181818182],...
'Style','text',...
'UserData',[],...
'Tag','WaitBar3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'UiPanelMapInfo';

h139 = uipanel(...
'Parent',h1,...
'FontName','Times New Roman',...
'Title','Map Info',...
'Tag','UiPanelMapInfo',...
'Clipping','on',...
'Position',[0.162869198312236 0.48911465892598 0.364556962025316 0.361393323657475],...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'InfosBox';

h140 = uicontrol(...
'Parent',h139,...
'Units','normalized',...
'FontAngle','italic',...
'FontName','Times New Roman',...
'FontSize',10.9999999999997,...
'HorizontalAlignment','left',...
'Position',[0.014018691588785 0.0553191489361702 0.953271028037383 0.940425531914894],...
'String','Dialog box',...
'Style','text',...
'UserData',[],...
'Tag','InfosBox',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'UiPanelOptions';

h141 = uipanel(...
'Parent',h1,...
'FontName','Times New Roman',...
'Title','XMapTools options',...
'Tag','UiPanelOptions',...
'UserData',[],...
'Clipping','on',...
'BackgroundColor',[0.933333333333333 0.933333333333333 0.933333333333333],...
'Position',[0.29620253164557 0.521044992743106 0.404219409282701 0.329462989840348],...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DisplayComments';

h142 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('DisplayComments_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'HorizontalAlignment','right',...
'Position',[0.0231578947368421 0.863849765258216 0.435789473684211 0.112676056338028],...
'String','Display help in XMapTools window',...
'Style','checkbox',...
'Value',1,...
'Tag','DisplayComments',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text18';

h143 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',8,...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[0.0167014613778706 0.0976744186046512 0.183716075156576 0.0790697674418604],...
'String','XMapTools directory:',...
'Style','text',...
'Tag','text18',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRAffichage0';

h144 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',7,...
'HorizontalAlignment','left',...
'Position',[0.206680584551148 0.106976744186046 0.774530271398747 0.0697674418604651],...
'String','...',...
'Style','text',...
'Tag','PRAffichage0',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text34';

h145 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',8,...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[0.0167014613778706 0.0325581395348837 0.162839248434238 0.0790697674418604],...
'String','Current directory:',...
'Style','text',...
'Tag','text34',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PRAffichage01';

h146 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontSize',7,...
'HorizontalAlignment','left',...
'Position',[0.204592901878914 0.0325581395348837 0.776617954070981 0.0744186046511628],...
'String','...',...
'Style','text',...
'Tag','PRAffichage01',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'title2';

h147 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontAngle','italic',...
'FontName','Times New Roman',...
'FontSize',9,...
'FontWeight','bold',...
'Position',[0.810526315789474 0.187793427230047 0.172631578947368 0.0516431924882629],...
'String','Version 1.X.X',...
'Style','text',...
'Tag','title2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PopUpColormap';

h148 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('PopUpColormap_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.227368421052632 0.544600938967136 0.181052631578947 0.136150234741784],...
'String',{  'Jet'; 'WYRK'; 'Hot'; 'Gray'; 'HSV'; 'Cool'; 'Spring'; 'Summer'; 'Autumn'; 'Winter'; 'Bone'; 'Copper'; 'Pink' },...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)VER_XMapTools_750('PopUpColormap_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'UserData',[],...
'Tag','PopUpColormap');

appdata = [];
appdata.lastValidTag = 'ActivateDiary';

h149 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ActivateDiary_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'HorizontalAlignment','right',...
'Position',[0.589473684210526 0.863849765258216 0.351578947368421 0.112676056338028],...
'String','Activate the "Diary"',...
'Style','checkbox',...
'Tag','ActivateDiary',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DisplayActions';

h150 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('DisplayActions_Callback',hObject,eventdata,guidata(hObject)),...
'Enable','off',...
'FontName','Times New Roman',...
'HorizontalAlignment','right',...
'Position',[0.0231578947368421 0.765258215962441 0.501052631578947 0.112676056338028],...
'String','Display actions in MATLAB command window',...
'Style','checkbox',...
'Value',1,...
'Tag','DisplayActions',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DisplayCoordinates';

h151 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('DisplayCoordinates_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'HorizontalAlignment','right',...
'Position',[0.589473684210526 0.765258215962441 0.341052631578947 0.112676056338028],...
'String','Display live coordinates',...
'Style','checkbox',...
'Value',1,...
'Tag','DisplayCoordinates',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text82';

h152 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'FontName','Times New Roman',...
'HorizontalAlignment','left',...
'Position',[0.0315789473684211 0.568075117370892 0.191578947368421 0.103286384976526],...
'String','Figure''s colormap',...
'Style','text',...
'Tag','text82',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonSaveSettings';

h153 = uicontrol(...
'Parent',h141,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonSaveSettings_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.448421052631579 0.2018779342723 0.15 0.09],...
'String','Save default',...
'Tag','ButtonSaveSettings',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'REbutton6';

h154 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('REbutton6_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'FontWeight','bold',...
'Position',[0.00675105485232068 0.439767779390421 0.070042194092827 0.0333817126269956],...
'String','TriPlot3D',...
'Tag','REbutton6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text83';

h155 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.00843881856540084 0.509433962264151 0.0658227848101266 0.02322206095791],...
'String','Modules',...
'Style','text',...
'UserData',[],...
'Tag','text83',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PanelArrows';

h156 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'FontName','Times New Roman',...
'Title',blanks(0),...
'Tag','PanelArrows',...
'Clipping','on',...
'Position',[0.00337552742616034 0.281567489114659 0.0767932489451477 0.0928882438316401],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonUp';

h157 = uicontrol(...
'Parent',h156,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonUp_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.362637362637363 0.609375 0.252747252747253 0.34375],...
'String','Up',...
'Tag','ButtonUp',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonDown';

h158 = uicontrol(...
'Parent',h156,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonDown_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.362637362637363 0.171875 0.252747252747253 0.34375],...
'String','Do',...
'Tag','ButtonDown',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonRight';

h159 = uicontrol(...
'Parent',h156,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonRight_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.65934065934066 0.390625 0.252747252747253 0.34375],...
'String','Ri',...
'Tag','ButtonRight',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonLeft';

h160 = uicontrol(...
'Parent',h156,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonLeft_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.065934065934066 0.40625 0.252747252747253 0.34375],...
'String','Le',...
'Tag','ButtonLeft',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text84';

h161 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.00843881856540084 0.380261248185777 0.0658227848101266 0.02322206095791],...
'String','X-pad',...
'Style','text',...
'UserData',[],...
'Tag','text84',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text85';

h162 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.00759493670886076 0.190130624092888 0.0658227848101266 0.02322206095791],...
'String','Corrections',...
'Style','text',...
'UserData',[],...
'Tag','text85',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'CorrButtonBRC';

h163 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('CorrButtonBRC_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0143459915611814 0.152394775036284 0.0531645569620253 0.0304789550072569],...
'String','BRC',...
'Style','togglebutton',...
'Tag','CorrButtonBRC',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonXPadApply';

h164 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonXPadApply_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.0194092827004219 0.249637155297533 0.0447257383966245 0.0391872278664732],...
'String','APPLY',...
'Tag','ButtonXPadApply',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'BUsampling4';

h165 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('BUsampling4_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.0540084388185654 0.602322206095791 0.0194092827004219 0.0319303338171263],...
'String','SR',...
'Tag','BUsampling4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ADMINbutton1';

h166 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ADMINbutton1_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'Position',[0.481856540084388 0.956458635703919 0.0194092827004219 0.0319303338171263],...
'String','AD',...
'UserData',[],...
'Tag','ADMINbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ButtonSettings';

h167 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)VER_XMapTools_750('ButtonSettings_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.507172995780591 0.956458635703919 0.019409282700422 0.0319303338171263],...
'String','SE',...
'Tag','ButtonSettings',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'UiPanelAdmin';

h168 = uipanel(...
'Parent',h1,...
'BorderType','none',...
'BorderWidth',0,...
'FontName','Times New Roman',...
'Title',blanks(0),...
'Tag','UiPanelAdmin',...
'Clipping','on',...
'Position',[0.000843881856540084 0.0145137880986938 0.080168776371308 0.124818577648766],...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DebugMode';

h169 = uicontrol(...
'Parent',h168,...
'Units','normalized',...
'BackgroundColor',[0 0 0],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('DebugMode_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'ForegroundColor',[0.0784313725490196 0.168627450980392 0.549019607843137],...
'Position',[0.0736842105263158 0.686046511627907 0.252631578947368 0.255813953488372],...
'String','De',...
'UserData',[],...
'Tag','DebugMode',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'MaskButton8';

h170 = uicontrol(...
'Parent',h168,...
'Units','normalized',...
'BackgroundColor',[0 0 0],...
'Callback',@(hObject,eventdata)VER_XMapTools_750('MaskButton8_Callback',hObject,eventdata,guidata(hObject)),...
'FontName','Times New Roman',...
'FontWeight','bold',...
'Position',[0.357894736842105 0.686046511627907 0.252631578947368 0.255813953488372],...
'String','Gb',...
'UserData',[],...
'Tag','MaskButton8',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % VER_XMAPTOOLS_750
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % VER_XMAPTOOLS_750(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % VER_XMAPTOOLS_750('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % VER_XMAPTOOLS_750(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);  
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end            
        end
    end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


