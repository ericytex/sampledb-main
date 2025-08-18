# SampleDB Changelog - Version 2.0.0+

## 🚀 New Features

### Dual qPCR Download Functionality
- **QuantStudio Format**: `.txt` export with QuantStudio-specific headers
- **BioRad Format**: `.txt` export with BioRad-specific headers  
- **Both use 96-well plates** (A1-H12)
- **Filename patterns**: `qPCR_QuantStudio_[Plate]_[Date].txt` and `qPCR_BioRad_[Plate]_[Date].txt`

## 🛠️ Bug Fixes

### ContainerAction ID Conflict Resolution
- **Issue**: Shiny warning "Shared input/output ID was found"
- **Solution**: Renamed output ID from `ContainerAction` to `ContainerActionButton`
- **Impact**: Eliminates warnings, improves stability

## 📁 Files Modified

1. **`UISearchDelArchSamples.R`**: Added dual qPCR download buttons
2. **`AppSearchDelArchSamples.R`**: Implemented separate handlers, enhanced functions
3. **`UIEditContainers.R`**: Fixed ID conflict
4. **`AppEditContainers.R`**: Updated server references

## 🔧 Technical Details

- **Database Enhancements**: Auto-generation of malaria_blood_control_id for CTRL samples
- **Validation Logic**: Single plate requirement, 96-well validation, missing wells handling
- **Export Structure**: Tab-delimited files with instrument-specific formatting
- **Error Handling**: User-friendly modals and progress notifications

## 📊 Statistics

- **Files Modified**: 4
- **Lines Added**: ~200+
- **New Features**: 2
- **Bug Fixes**: 1
- **Database Enhancements**: Multiple

## 🚀 Deployment

```bash
# Remove old package
R -e "remove.packages('sampleDB')"

# Install updated package  
R -e "remotes::install_local('.', dependencies = TRUE, force = TRUE)"

# Run application
R -e "library(sampleDB); Run_SampleDB()"
```

## 🎯 Summary

Major enhancement adding professional qPCR export capabilities while improving code quality and fixing critical bugs. Both QuantStudio and BioRad formats now supported with proper 96-well plate validation.

*Generated: August 18, 2025*
