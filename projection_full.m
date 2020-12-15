%% written by PJH from 2020.11.17~
% xml read, find x, y margin, export projection image

%% initialization
clear all; clc;

%% setting
export_directory = 'C:\Users\NPL_opticroom\Documents\MATLAB\export\';
% if this value is 1, check every pixel and find 0.2% value
check_001 = 0;
%multiplier, increase image brightness
multiplier = 20000;

%% load file
imgfname = uigetfile('*.tif');
trcfname = uigetfile('*.xml');

%% read image file info
info = imfinfo(imgfname,'tif');
full_image = imread_big(imgfname);
num_images = numel(full_image(1,1,:)); %numel(info);
Width = info.Width;
Height = info.Height;


%% get information about trace vector
% read xml file
temp_trc = parseXML(trcfname); 
num_myelin = (numel(temp_trc(2).Children) - 5 )/ 2;

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
    if (Width < initial_x || 0 > initial_x) 
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
    
    %% set export range(margin), include +-100 around vector initial, final
    %point
    export_x_right = min( [Width, max([initial_x, final_x]) + 200 ]);
    export_x_left = max( [1, min( [initial_x, final_x]) - 200 ]) ;
    export_y_up = min( [Height, max( [initial_y, final_y]) + 200 ]) ;
    export_y_down = max( [1, min( [initial_y, final_y]) - 200 ]) ;
    export_z_front = max( [1, min( [initial_z, final_z]) - 10 ]);
    export_z_back = min( [num_images, max( [initial_z, final_z]) + 10 ]); 
    
    %% Adjust image histogram
    % find image value at 0.2% and rewrite, image value
    if check_001 == 1
        pixel_number_1per = fix(Width * Height * (export_z_back - export_z_front) / 500);
        reshaped_iamge = reshape(full_image(:,:,export_z_front : export_z_back), 1,[]);
        brightest_pixel = maxk(reshaped_iamge, pixel_number_1per);
        pixel_001 = brightest_pixel(pixel_number_1per);
    else
       pixel_001 = 150;
    end
        
    %% image projection. comapre each pixel and overwrite brighter one. 
    % first image used as a template 
    export_image = full_image(:,:,export_z_front);

    for k = export_z_front:export_z_back
        temp_image = fix(full_image(:,:,k) * (multiplier / pixel_001) );

        for i = export_x_left:export_x_right
            for j = export_y_down:export_y_up
                if (export_image(j,i) < temp_image(j,i))
                    export_image(j,i) = temp_image(j,i);
                end
            end
        end
        
    end
    
   %% mark initial and final point and crop export image 
   export_image(initial_y + 8 : initial_y + 10 , max(initial_x  - 4, 1) : initial_x + 4) = 60000;
   export_image(final_y + 8 : final_y + 10 , max(final_x - 2, 1) : final_x +2) = 60000;
   export_image = export_image(export_y_down : export_y_up, export_x_left : export_x_right);
    
    %% export projection as a JPEG file
    export_filename = strcat(export_directory,myelin_name,'.png');
    imwrite(export_image,export_filename,'BitDepth',16);

end