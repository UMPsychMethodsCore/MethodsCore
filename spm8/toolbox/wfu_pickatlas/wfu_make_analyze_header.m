function  analyze_hdr = make_analyze_header()

%------------------------------------------------------------------
%This constructs an analyze header
%It includes magnet transform and landmark fields
%this assumes 1 bytarr = 1 char
%header measures 348 when written
%------------------------------------------------------------------
analyze_hdr.sizeof_hdr.value = 348;
analyze_hdr.sizeof_hdr.type = 'int32';
analyze_hdr.sizeof_hdr.size = 1;

analyze_hdr.data_type.value = zeros(1,10);
analyze_hdr.data_type.type = 'char';
analyze_hdr.data_type.size = [1 10];

analyze_hdr.db_name.value = zeros(1,18);
analyze_hdr.db_name.type = 'char';
analyze_hdr.db_name.size = [1 18];

analyze_hdr.extents.value = 16384;
analyze_hdr.extents.type = 'int32';
analyze_hdr.extents.size = 1;

analyze_hdr.session_error.value = 29184;
analyze_hdr.session_error.type = 'int16';
analyze_hdr.session_error.size = 1;

analyze_hdr.regular.value = 'r';
analyze_hdr.regular.type = 'char';
analyze_hdr.regular.size = 1;
		
analyze_hdr.hkey_un0.value = '0';
analyze_hdr.hkey_un0.type = 'char';
analyze_hdr.hkey_un0.size = 1;

analyze_hdr.dims.value = 4;
analyze_hdr.dims.type = 'int16';
analyze_hdr.dims.size = 1;

analyze_hdr.x_dim.value = 0;
analyze_hdr.x_dim.type = 'int16';
analyze_hdr.x_dim.size = 1;

analyze_hdr.y_dim.value = 0;
analyze_hdr.y_dim.type = 'int16';
analyze_hdr.y_dim.size = 1;

analyze_hdr.z_dim.value = 0;
analyze_hdr.z_dim.type = 'int16';
analyze_hdr.z_dim.size = 1;

analyze_hdr.t_dim.value = 0;
analyze_hdr.t_dim.type = 'int16';
analyze_hdr.t_dim.size = 1;

analyze_hdr.rest_of_dim.value = zeros(1, 3);
analyze_hdr.rest_of_dim.type = 'int16';
analyze_hdr.rest_of_dim.size = [1 3];

analyze_hdr.vox_units.value = zeros(1, 4);
analyze_hdr.vox_units.type = 'char';
analyze_hdr.vox_units.size = [1 4];

analyze_hdr.cal_units.value = zeros(1, 8);
analyze_hdr.cal_units.type = 'char';
analyze_hdr.cal_units.size = [1 8];

analyze_hdr.unused1.value = 0;
analyze_hdr.unused1.type = 'int16';
analyze_hdr.unused1.size = 1;

analyze_hdr.datatype.value = 0;
analyze_hdr.datatype.type = 'int16';
analyze_hdr.datatype.size = 1;

analyze_hdr.bits.value = 0;
analyze_hdr.bits.type = 'int16';
analyze_hdr.bits.size = 1;

analyze_hdr.dim_un0.value = 0;
analyze_hdr.dim_un0.type = 'int16';
analyze_hdr.dim_un0.size = 1;

analyze_hdr.pixdim0.value = 0;
analyze_hdr.pixdim0.type = 'float32';
analyze_hdr.pixdim0.size = 1;

analyze_hdr.x_size.value = 0;
analyze_hdr.x_size.type = 'float32';
analyze_hdr.x_size.size = 1;

analyze_hdr.y_size.value = 0;
analyze_hdr.y_size.type = 'float32';
analyze_hdr.y_size.size = 1;

analyze_hdr.z_size.value = 0;
analyze_hdr.z_size.type = 'float32';
analyze_hdr.z_size.size = 1;

analyze_hdr.rest_of_pixdim.value = zeros(1, 4);
analyze_hdr.rest_of_pixdim.type = 'float32';
analyze_hdr.rest_of_pixdim.size = [1 4];

analyze_hdr.vox_offset.value = 0;
analyze_hdr.vox_offset.type = 'float32';
analyze_hdr.vox_offset.size = 1;

analyze_hdr.scale.value = 0;
analyze_hdr.scale.type = 'float32';
analyze_hdr.scale.size = 1;

analyze_hdr.funused2.value = 0;
analyze_hdr.funused2.type = 'float32';
analyze_hdr.funused2.size = 1;

analyze_hdr.funused3.value = 0;
analyze_hdr.funused3.type = 'float32';
analyze_hdr.funused3.size = 1;

analyze_hdr.cal_max.value = 0;
analyze_hdr.cal_max.type = 'float32';
analyze_hdr.cal_max.size = 1;

analyze_hdr.cal_min.value = 0;
analyze_hdr.cal_min.type = 'float32';
analyze_hdr.cal_min.size = 1;

analyze_hdr.compressed.value = 0;
analyze_hdr.compressed.type = 'int32';
analyze_hdr.compressed.size = 1;

analyze_hdr.verified.value = 0;
analyze_hdr.verified.type = 'int32';
analyze_hdr.verified.size = 1;

analyze_hdr.glmax.value = 0;
analyze_hdr.glmax.type = 'int32';
analyze_hdr.glmax.size = 1;

analyze_hdr.glmin.value = 0;
analyze_hdr.glmin.type = 'int32';
analyze_hdr.glmin.size = 1;

analyze_hdr.descrip.value = zeros(1, 80);
analyze_hdr.descrip.type = 'char';
analyze_hdr.descrip.size = 80;

analyze_hdr.pad7.value = zeros(1, 24);
analyze_hdr.pad7.type = 'char';
analyze_hdr.pad7.size = 24;

analyze_hdr.orient.value = '0';
analyze_hdr.orient.type = 'uchar';
analyze_hdr.orient.size = 1;

analyze_hdr.orig.value = zeros(1, 4);
analyze_hdr.orig.type = 'int16';
analyze_hdr.orig.size = 4;

analyze_hdr.magnet_transform.value = eye(4);
analyze_hdr.magnet_transform.type = 'float32';
analyze_hdr.magnet_transform.size = [4 4];

analyze_hdr.landmark.value = 0;
analyze_hdr.landmark.type = 'float32';
analyze_hdr.landmark.size = 1;

analyze_hdr.pad8.value = zeros(1, 19);
analyze_hdr.pad8.type = 'char';
analyze_hdr.pad8.size = 19;		

analyze_hdr.extents.value = 16384;
analyze_hdr.sizeof_hdr.value = 348;

analyze_hdr.vox_units.value(1:2) = 'm';


return

