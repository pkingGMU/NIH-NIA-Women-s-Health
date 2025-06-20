# Axivity Activity & Posture Classification

This repository contains MATLAB code for classifying **physical activity** and **postural behavior** using triaxial accelerometer data collected from Axivity AX3 devices. The pipeline processes raw `.cwa` files, extracts relevant motion features, and classifies windows of time into activity types (active vs. inactive) and postures (lying, sitting, or standing).

---

## Overview

The script performs the following major steps:

1. **Data Import** – Load `.cwa` files using OpenMovement's Axivity reader functions.
2. **Preprocessing** – Apply median filtering and low-pass filtering to isolate gravity.
3. **Postural Classification** – Classify posture by computing the angle of acceleration relative to gravity.
4. **Activity Classification** – Use SVM-1 signal (sum of vector magnitudes minus 1g) to classify activity epochs as active or inactive.
5. **Visualization** – Overlay classification windows on time-series plots for visual inspection.

---

## Installation

### Option 1: GitHub Users (Familiar with Git)

1. Open your terminal or command prompt.
2. Clone the repository:
   ```bash
   git clone https://github.com/pkingGMU/NIH-NIA-Women-s-Health.git
   ```
3. Open MATLAB and navigate to the cloned project folder.

### Option 2: Non-GitHub Users (Unfamiliar with Git)

1. Visit the GitHub page: [https://github.com/pkingGMU/NIH-NIA-Women-s-Health](https://github.com/pkingGMU/NIH-NIA-Women-s-Health)
2. Click the green **Code** button and choose **Download ZIP**.
3. Extract the ZIP file to a location on your computer.
4. Open MATLAB and navigate to the extracted project folder.


## How to use

1. Place your `.cwa` files inside the `Data` folder following this structure:

```
Data/
  └── SubjectName/
        └── TrialName.cwa
```

2. Run `main.m`


