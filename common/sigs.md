### EEG

All EEG channels should have an explicit label in the form {active}_{reference}: e.g. `C3_M2` or `C3_LM`.

| Channel | Description          |
| ------- | -------------------- |
| `C3` `C4` `Cz` `F3` `F4` `F7` `F8` `Fz` `Fp1` `Fp2` `Fpz` <br>`O1` `O2` `P3` `P4` `Pg1` `Pg2` `Pz` `T3` `T4` `T5` `T6` | Standard EEG channels |
| `M1` `M2` | Mastoid references (`A1` and `A2` mapped to `M1` and `M2`) |
| `AVG`     | Average reference    |
| `LM`      | Linked mastoid reference |
| `REF`     | Unknown reference    |

### EOG

All EOG channels should have an explicit label in the form {active}_{reference}: e.g. `E1_M2` or `E2_M2`.

| Channel | Description                |
| ------- | -------------------------- |
| `E1`      | Left EOG                   |
| `E2`      | Right EOG                  |

### ECG

All ECG channels should have an explicit label in the form {active}_{reference}: e.g. `ECG1_ECG2` or `ECG1_ECG3`

| Channel    | Description             |
| ---------- | ----------------------- |
| `ECG`        | ECG, Unspecified: may be bipolar (ECG1 referenced to ECG2); or collected to a common reference  |
| `ECG1`      | ECG, Left subclavicular|
| `ECG2`      | ECG, Right subclavicular|
| `ECG3`       |ECG, Left rib cage or axillary|
| 'Ref'|          |Common reference|
| 'DHR'|    |Derived heart rate from ECG|
 |'PTT'|    |Time between ECG and pulse waveform|
### EMG

All EMG channels should have an explicit label in the form {active}_{reference}: e.g. `lchin_cchin` or `chin_Fpz`

| Channel  | Description                                   |
| -------- | --------------------------------------------- |
| `chin`         | Chin EMG, Unspecified reference|
| `lchin` `rchin` `cchin` | Chin EMG (left, right and central) |
| `larm` `rarm` | Left/right arm EMG |
| `lleg` `rleg` | Left/right leg EMG  |


### Respiratory

| Channel   | Description                      |
| --------- | -------------------------------- |
| `abdomen`   | Abdominal Effort                 |
| `cap`       | Capnography                      |
| `etco2`     | End Tidal CO2                    |
|          |
| `leak`      | CPAP Leak  (airflow leak during CPAP)                      |
| `nas_pres_notransform`  | Nasal Pressure (airflow, without square wave transform)
'nas_pres_transform' |        Nasal Pressure (airflow, with square wave transform)          |
| `pap_flow`  | CPAP flow  (flow signal)                      |
| `pap_pres`  | CPAP pressure (mmHg)                   |
| 
                           |
| `resprate`  | Respiratory Rate                 |
| `snore`     | Snore  (sound or vibration)                          |
| `spo2`      | Peripheral oxygen saturation                             |
| `sum`       | Sum of abdomen and thorax efforts                            |
| `tcco2`     | Transcutaneous CO2               |
| `therm`     | Thermistor Airflow (nasal-oral)                       |
| `thorax`    | Thoracic (Chest) Effort                  |
|                  |

### Misc

| Channel   | Description            |
| --------- | ---------------------- |
| `activity`  | Activity (movement from accelerometer)              |
|            |
|             |
|   |
| `elevation` | Elevation (body postion)             |
| `grav`      | Gravity  (position)              |
| `gravx`     | Gravity X  (position)            |
| `gravy`     | Gravity Y  (positio)            |
|            |
| `light`     | Light (ambient)                 |
| `man_pos` | Manual Position         |
| `oxstat`    | Oximeter Status        |
|                 |
| `pleth`     | Plethysmography        |
| `plethstat` | Plethysmography Status |
| `position`  | Body Position          |
|    |
| `pulse`     | Pulse   (heart rate from pulse oximeter)               |
|             |


