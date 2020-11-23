%% written by PJH 2020.11.17~
% xml read, find x, y margin, export projection image

%initialization
%clear all; clc;

%% load file
%tif file must be smaller than 4Gb. if larger than it, this function doesn't work.
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
% null1 = xmlread(trcfname);
% type(trcfname);
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
    
    if (Width < final_x || 0 > final_x)
        continue;
    end
   
    if (Height < initial_y || 0 > initial_y)
        continue;
    end
    
    if (Height < final_y || 0 > final_y)
        continue;
    end
    
    if (num_images < initial_z || 0 > initial_z)
        continue;
    end
    
    if (num_images < final_z || 0 > final_z)
        continue;
    end
    
    %% set export range(margin), include +-100 around vector initial, final
    %point
    export_x_right = min( [Width, max([initial_x, final_x]) + 200 ]);
    export_x_left = max( [0, min( [initial_x, final_x]) - 200 ]) ;
    export_y_up = min( [Height, max( [initial_y, final_y]) + 200 ]) ;
    export_y_down = max( [0, min( [initial_y, final_y]) - 200 ]) ;
    export_z_front = max( [0, min( [initial_z, final_z]) - 10 ]);
    export_z_back = min( [num_images, max( [initial_z, final_z]) + 10 ]); 

    %% image projection. comapre each pixel and overwrite brighter one. 
    % first image used as a template 
    export_image = full_image(:,:,1);

    for k = export_z_front:export_z_back
        temp_image = full_image(:,:,k);

        for i = export_x_left:export_x_right
            for j = export_y_down:export_y_up
                if (export_image(j,i) < temp_image(j,i))
                    export_image(j,i) = temp_image(j,i);
                end
            end
        end
        
    end
    
   %% mark initial and final point and crop export image 
   export_image(initial_y - 3 : initial_y + 3 , initial_x - 3 : initial_x + 3) = 255;
   export_image(final_y - 2 : final_y + 2 , final_x - 2 : final_x +2) = 255;
   export_image = export_image(export_y_down : export_y_up, export_x_left : export_x_right);
    
    %% export projection as a JPEG file
    %export_image = image(export_image);
    export_filename = strcat('C:\Users\NPL_opticroom\Documents\MATLAB\export\',myelin_name,'.png');
    imwrite(export_image,export_filename,'BitDepth',16);

end