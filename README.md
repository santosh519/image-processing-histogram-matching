# Histogram Matching for Stripe Removal in Landsat ETM+ Imagery

**Santosh Adhikari**  

---

A MATLAB implementation of row-based histogram matching to remove detector-induced stripe artifacts from Landsat 7 ETM+ imagery. By equalizing each of the 16 detector responses to a reference statistical profile, this tool restores radiometric uniformity, crucial for accurate remote-sensing analyses.

---

## 🔍 Key Features

- **Interactive band selection**  
  Choose any ETM+ band 1–5 or 7 at runtime.  
- **Per-detector analysis**  
  Computes mean, standard deviation, and histograms for each detector row-block.  
- **Global gain & bias correction**  
  Derives and applies optimal gain/bias to match each detector’s distribution to the reference.  
- **Comprehensive visualization**  
  Plots original vs. corrected histograms and displays side-by-side before/after images.  
- **Large-file support via Git LFS**  
  Manages GeoTIFFs seamlessly without exceeding GitHub’s file-size limits.

---

## ⚙️ Prerequisites

- **MATLAB** R2019b or later  
- **Image Processing Toolbox**  
- **Git** & **Git LFS** installed and configured  

---

## 🚀 Installation & Setup

1. **Clone** this repository:
   ```bash
   git clone https://github.com/santosh519/image-processing-histogram-matching.git
   cd image-processing-histogram-matching

2. **Initialize** Git LFS and fetch the TIFFs:
git lfs install
git lfs pull

3. Ensure the six ETM_B*.tif files appear under the Images/ folder.

---

## ▶️ Usage

1. Open MATLAB and set the Current Folder to the project root.

2. In the Command Window, run:

   ```matlab
   removing_stripes_from_images_using_histogram_matching


When prompted, enter a valid band number: 1, 2, 3, 4, 5, or 7.

Review the outputs:

- Histogram of the original and corrected image
- Pre- and post-correction histograms for each detector
- Original vs. corrected images
- (Optional) Console table of detector gains & biases

---

## 📈 Sample Results

| Original ETM+ Band 2 Image            | Corrected ETM+ Band 2 Image           |
|:-------------------------------:|:-------------------------------:|
| ![Original](<results/Band 2 Image Before Correction.png>) | ![Corrected](<results/Band 2 Image After Correction.png>) |

---

## 👤 Author & Contact
Santosh Adhikari

Email: santadh2015@gmail.com

GitHub: @santosh519

Thank you for reviewing! Feedback and contributions are welcome.
