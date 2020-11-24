%% written by Jeonghyeon Park from 2020.11.17~
% need xml(oligodendrocyte trace) and tiff(tissue image) with multiple images
% unzip .traces file to get xml file
% find x, y margin, z margin, file directory could be set
% require parseXML.m and imread_big.m fo operation 

%% initialization
clear all; clc;

%% setting
export_directory = 'C:\Users\NPL_opticroom\Documents\MATLAB\export\';
%margin around start point
xymargin = 200;
zmargin = 20;
%xls file output
xlsoutput = 1;
xls_export_directory = 'C:\Users\NPL_opticroom\Documents\MATLAB\export\# OL xy 0.302 z 1 Exratio 4.xlsx';
%multiplier, increase image brightness
multiplier = 30000;

%% load tif, xml file
imgfname = uigetfile('*.tif');
trcfname = uigetfile('*.xml');

%% read image file info
info = imfinfo(imgfname,'tif');
full_image = imread_big(imgfname);
num_images = numel(full_image(1,1,:));
Width = info.Width;
Height = info.Height;

%% get informations about trace vector
temp_trc = parseXML(trcfname); 
num_myelin = (numel(temp_trc(2).Children) - 5 )/ 2;

%% xls file setting
xls = strings(num_myelin,4);
l = 1; 

%% track myelin
for i1 = 1:num_myelin 
   
    num_column =  4 + 2 * i1;
    final_column = numel(temp_trc(2).Children(num_column).Children) - 1 ;
    
    %% initial and final coordinate of vector
    initial_x = str2double(temp_trc(2).Children(num_column).Children(2).Attributes(1).Value);
    initial_y = str2double(temp_trc(2).Children(num_column).Children(2).Attributes(3).Value);
    initial_z = str2double(temp_trc(2).Children(num_column).Children(2).Attributes(5).Value);
    
    final_x = str2double(temp_trc(2).Children(num_column).Children(final_column).Attributes(1).Value);
    final_y = str2double(temp_trc(2).Children(num_column).Children(final_column).Attributes(3).Value);
    final_z =str2double(temp_trc(2).Children(num_column).Children(final_column).Attributes(5).Value);
    
    %% chek if it is myelin, not cell body
    myelin_name = temp_trc(2).Children(num_column).Attributes(5).Value;
   if (contains(myelin_name,'M'))
   else
       continue;
   end

    %% check trace is within range
    if (Width < initial_x || 1 > initial_x) 
        continue;
    end
    
    if (Width < final_x || 1 > final_x)
        continue;
    end
   
    if (Height < initial_y || 1 > initial_y)
        continue;
    end
    
    if (Height < final_y || 1 > final_y)
        continue;
    end
    
    if (num_images < initial_z || 1 > initial_z)
        continue;
    end
    
    if (num_images < final_z || 1 > final_z)
        continue;
    end
    
    %% set export range(margin), include +-100 around 
    % vector initial, final point
    export_x_right_1 = min( [Width, initial_x + xymargin ] );
    export_x_left_1 = max( [1, initial_x - xymargin ] ) ;
    export_y_up_1 = min( [Height, initial_y + xymargin ] ) ;
    export_y_down_1 = max( [1, initial_y - xymargin ] ) ;
    export_z_front_1 = max( [1, initial_z - zmargin ] );
    export_z_back_1 = min( [num_images, initial_z + zmargin ] ); 
    
    export_x_right_2 = min( [Width, final_x + xymargin ] );
    export_x_left_2 = max( [1, final_x - xymargin ] ) ;
    export_y_up_2 = min( [Height, final_y + xymargin ] ) ;
    export_y_down_2 = max( [1, final_y - xymargin ] ) ;
    export_z_front_2 = max( [1, final_z - zmargin ] );
    export_z_back_2 = min( [num_images, final_z + zmargin ] ); 

    %% Adjust image histogram
    % find image value at 0.2% and rewrite, image value
    pixel_number_1per = fix(Width * Height * (export_z_back_1 - export_z_front_1) / 500);
    reshaped_iamge = reshape(full_image(:,:,export_z_front_1 : export_z_back_1), 1,[]) ;
    brightest_pixel = maxk(reshaped_iamge, pixel_number_1per);
    pixel_001 = brightest_pixel(pixel_number_1per);
    
    pixel_number_1per = fix(Width * Height * (export_z_back_2 - export_z_front_2) / 500);
    reshaped_iamge = reshape(full_image(:,:,export_z_front_2 : export_z_back_2), 1,[]) ;
    brightest_pixel = maxk(reshaped_iamge, pixel_number_1per);
    pixel_002 = brightest_pixel(pixel_number_1per);
    
    %% image projection. comapre each pixel and overwrite brighter one. 
    % first image used as a template 
    
    export_image_1 = full_image(:,:,export_z_front_1);

    for k = export_z_front_1 : export_z_back_1
        temp_image =  fix(full_image(:,:,k) * (multiplier / pixel_001) );
        
        for i = export_x_left_1 : export_x_right_1
            for j = export_y_down_1 : export_y_up_1
                if (export_image_1(j,i) < temp_image(j,i))
                    export_image_1(j,i) = temp_image(j,i);
                end
            end 
        end
    end
        
    export_image_2 = full_image(:,:,export_z_front_2);

    for k = export_z_front_2 : export_z_back_2
        temp_image = fix(full_image(:,:,k) * (multiplier / pixel_001) );

        for i = export_x_left_2 : export_x_right_2
            for j = export_y_down_2 : export_y_up_2
                if (export_image_2(j,i) < temp_image(j,i))
                    export_image_2(j,i) = temp_image(j,i);
                end
            end
        end
    end
        
   %% mark initial and final point and crop export image 
   export_image_1(initial_y + 8 : initial_y + 10 , initial_x  - 4 : initial_x + 4) = 60000;
   export_image_2(final_y + 8 : final_y + 10 , final_x - 2 : final_x +2) = 60000;
   export_image_1 = export_image_1(export_y_down_1 : export_y_up_1, export_x_left_1 : export_x_right_1);
   export_image_2 = export_image_2(export_y_down_2 : export_y_up_2, export_x_left_2 : export_x_right_2);
    
    %% export projection as a JPEG file
    %export_image = image(export_image);
    export_filename_1 = strcat(export_directory,myelin_name,'I','.png');
    export_filename_2 = strcat(export_directory,myelin_name,'F','.png');
    imwrite(export_image_1,export_filename_1,'BitDepth',16);
    imwrite(export_image_2,export_filename_2,'BitDepth',16);
    
    if xlsoutput == 1
         xls(l,4) = myelin_name; 
         l = l+1;
    end
    
end

writematrix(xls,xls_export_directory,'Sheet',1,'Range','A1')