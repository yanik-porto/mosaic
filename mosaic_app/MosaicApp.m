function varargout = MosaicApp(varargin)
% MOSAICAPP MATLAB code for MosaicApp.fig
%      MOSAICAPP, by itself, creates a new MOSAICAPP or raises the existing
%      singleton*.
%
%      H = MOSAICAPP returns the handle to a new MOSAICAPP or the handle to
%      the existing singleton*.
%
%      MOSAICAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOSAICAPP.M with the given input arguments.
%
%      MOSAICAPP('Property','Value',...) creates a new MOSAICAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MosaicApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MosaicApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MosaicApp

% Last Modified by GUIDE v2.5 14-Apr-2016 16:44:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MosaicApp_OpeningFcn, ...
                   'gui_OutputFcn',  @MosaicApp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MosaicApp is made visible.
function MosaicApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MosaicApp (see VARARGIN)

% Choose default command line output for MosaicApp
handles.output = hObject;
axes = handles.axesPanorama;
axis off;
set(handles.pushbuttonBuild,'Enable','off');
set(handles.pushbuttonSave,'Enable','off');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MosaicApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MosaicApp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonOpen.
function pushbuttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.inPath = '';

%Get info from handles
panel = handles.uipanelImg;
%Get images folder path 
folder_path = uigetdir;

%Display images
images = imageSet(folder_path);
for i=1:images.Count
    I = read(images,i);
    axImg = axes(panel,'Position',[0.1 0.62-(i-1)*0.21 0.8 0.5]);
    imshow(I,'Parent',axImg);
end
%Save the path 
handles.inPath = folder_path;
set(handles.pushbuttonBuild,'Enable','on');
guidata(hObject,handles);


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open dialog box
[file,path] = uiputfile('panorama.png','Save file name');
imwrite(handles.mosaic, [path, file]);

% --- Executes on button press in pushbuttonBuild.
function pushbuttonBuild_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBuild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get handles info
folder_path = handles.inPath;
axes = handles.axesPanorama;

switch get(get(handles.uibuttongroupCtrl,'SelectedObject'),'Tag')
    case 'radiobuttonHarris', method = 'Harris';
    case 'radiobuttonSurf', method = 'SURF';
    case 'radiobuttonFast', method = 'FAST';
end

%Build the panorama
panorama = build_panorama(folder_path, method);
handles.mosaic = panorama;
%Display in the axes
imshow(panorama,'Parent', axes);

set(handles.pushbuttonSave,'Enable','on');
guidata(hObject,handles);
