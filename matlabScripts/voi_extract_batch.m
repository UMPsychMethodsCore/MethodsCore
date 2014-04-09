function [Y,xY] = voi_extract_batch(varargin)
%created by Mike Angstadt for batch VOI extraction

if (length(varargin) ~= 11 && length(varargin) ~= 0)
  warning('incorrect use of voi_extract_batch - wrong number of inputs');
  error('usage: voi_extract_batch(path, contrast, threshold, extent, name, session, def, spec, xyz, mask, adjust#)');
end

if (length(varargin) == 0)
  m_path = [];
  m_contrast = [];
  m_threshold = [];
  m_extent = [];
  m_name = [];
  m_session = [];
  m_def = [];
  m_spec = [];
  m_xyz = [];
  m_mask = [];
  m_adj = 0;
else
  m_path = varargin{1};
  m_contrast = varargin{2};
  m_threshold = varargin{3};
  m_extent = varargin{4};
  m_name = varargin{5};
  m_session = varargin{6};
  m_def = varargin{7};
  m_spec = varargin{8};
  m_xyz = varargin{9};
  m_mask = varargin{10};
  m_adj = varargin{11};
end

spm('defaults', 'fmri');
global defaults;
global UFp;

if (isempty(m_path))
  [hReg,xSPM,SPM] = mike_results_ui;
else
  [hReg,xSPM,SPM] = mike_results_ui('setup', m_path, m_contrast, m_threshold, m_extent);
end

if (isempty(m_name))
  [Y,xY] = mike_regions(xSPM,SPM,hReg);
else
  [Y,xY] = mike_regions(xSPM,SPM,hReg,m_name, m_session, m_def, m_spec, m_xyz, m_mask,m_adj);
end

