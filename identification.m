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

for i1 = 1:num_myelin 
   %% chek if it is myelin, not cell body
   myelin_name = string( xls_data{i1,4} );

   %% export image as one figure
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
    
    subplot(2, 2, 1:2);
    imshow(fig3);
    
    subplot(2,2,3);
    imshow(fig1);
    
    subplot(2,2,4);
    imshow(fig2);
    
    %% indentify oligodendrocyte porperties 
    start_continuous = input('myelin start \n 0;isolated, 1;continuous, 2;broken');
    end_continuous = input('myelin end \n 0;isolated, 1;continuous, 2;broken');
    start_maturation = input('maturation start \n 0;immature ,1:intermediate, 2;mature');
    end_maturation = input('maturation end \n 0;immature ,1:intermediate, 2;mature');
    
end

%% export table as xlsx file
writetable(xls_data,export_directory,'Sheet',1,'Range','A1')