%% written by Jeonghyeon Park 2020.11.20~
% need xml with oligodendrocyte trace information
% unzip .traces file to get xml file

%% initialization
clear all; clc;
 
%% setting
input_directory = 'C:\Users\NPL_opticroom\Documents\MATLAB\export\';
export_directory = 'C:\Users\NPL_opticroom\Documents\MATLAB\export\export.xlsx';

%% load xml file
xlsfname = uigetfile('*.xlsx');

%% read xls file 
xls_data = readtable(xlsfname);

%% get numbers of myelin
num_myelin = numel(xls_data(1,:));

output = 0;

for i1 = 1:num_myelin 
   %% chek if it is myelin, not cell body
   myelin_name = string( xls_data{i1,4} );

   %% export images as one figure
   % file 1; initial image, file 2; final image, file 3; full myelin
    export_filename_1 = strcat(input_directory,myelin_name,'I','.png');
    export_filename_2 = strcat(input_directory,myelin_name,'F','.png');
    export_filename_3 = strcat(input_directory,myelin_name,'.png');
    
    %% chek whether file exist
    if isfile(export_filename_1) && isfile(export_filename_2) && isfile(export_filename_3)
    else
        continue;
    end
    
    fig1 = imread(export_filename_1);
    fig2 = imread(export_filename_2);
    fig3 = imread(export_filename_3);
    
    t = tiledlayout(1,3,'TileSpacing','Compact','Padding','Compact');
    
    nexttile
    imshow(fig3);
    title(t,myelin_name)
    
    nexttile
    imshow(fig1);
    title('Start point')

    nexttile
    imshow(fig2);
    title('End point')
    
    %% indentify oligodendrocyte porperties 
    start_continuous = input('Press any key to continue');
    
    output  = output +1;
end

if output == 0
    disp('wrong image or excel file');
end

%% export table as xlsx file
writetable(xls_data,export_directory,'Sheet',1,'Range','A1')