### EEG

All EEG channels should have an explicit in the form {active}_{reference}: e.g. `C3_M2` or `C3_LM`.

| Channel | Description          |
| ------- | -------------------- |
| `C3` `C4` `Cz` `F3` `F4` `F7` `F8` `Fz` `Fp1` `Fp2` `Fpz` <br>`O1` `O2` `P3` `P4` `Pg1` `Pg2` `Pz` `T3` `T4` `T5` `T6` | Standard EEG channels |
| `M1` `M2` | Mastoid references (`A1` and `A2` mapped to `M1` and `M2`) |
| `AVG`     | Average reference    |
| `LM`      | Linked mastoid reference |
| `REF`     | Unknown reference    |

### EOG

All EOG channels should have an explicit in the form {active}_{reference}: e.g. `E1_M2` or `E2_M2`.

| Channel | Description                |
| ------- | -------------------------- |
| `E1`      | Left EOG                   |
| `E2`      | Right EOG                  |

### ECG

All ECG channels should have an explicit in the form {active}_{reference}: e.g. `ECG1_ECG2` or `ECG1_ECG3`

| Channel    | Description             |
| ---------- | ----------------------- |
| `ECG`        | ECG, may be bipolar, e.g  ECG1 referenced to ECG2  |
| `ECG1`      |  ECG1 electrode|
| `ECG2`      |  ECG2 electrode|
| `ECG3`       |  ECG3 electrode|

### EMG

All EMG channels should have an explicit in the form {active}_{reference}: e.g. `lchin_cchin` or `chin_Fpz`

| Channel  | Description                                   |
| -------- | --------------------------------------------- |
| `chin`         | Chin EMG|
| `lchin` `rchin` `cchin` | Chin EMG (left, right and central) |
| `larm` `rarm` | Left/right arm EMG |
| `lleg` `rleg` | Left/right leg EMG  |


### Respiratory

| Channel   | Description                      |
| --------- | -------------------------------- |
| `abdomen`   | Abdominal Effort                 |
| `altflow`   | Alternate flow channnel          |
| `cap`       | Capnography                      |
| `dif_pres`  | Differential Pressure            |
| `etco2`     | End Tidal CO2                    |
| `ex_pres`   | Expiratory Pressure              |
| `flow`      | Airflow                          |
| `in_pres`   | Inspiratory Pressure             |
| `leak`      | CPAP Leak                        |
| `nas_pres`  | Nasal Pressure                   |
| `pap_flow`  | CPAP flow                        |
| `pap_pres`  | CPAP pressure                    |
| `pao2`      | PaO2                             |
| `resprate`  | Respiratory Rate                 |
| `snore`     | Snore                            |
| `spo2`      | SpO2                             |
| `sum`       | Sum                              |
| `tcco2`     | Transcutaneous CO2               |
| `therm`     | Thermistor                       |
| `thorax`    | Thoracic Effort                  |
| `tvol`      | Tidal Volume                     |

### Misc

| Channel   | Description            |
| --------- | ---------------------- |
| `activity`  | Activity               |
| `battery`   | Battery                |
| `cap`       | Capnography            |
| `DHR`       | Derived Heart Rate     |
| `elevation` | Elevation              |
| `grav`      | Gravity                |
| `gravx`     | Gravity X              |
| `gravy`     | Gravity Y              |
| `hr`        | Heart Rate             |
| `light`     | Light                  |
| `man_pos` | Manual Position        |
| `oxstat`    | Oximeter Status        |
| `phase`     | Phase                  |
| `pleth`     | Plethysmography        |
| `plethstat` | Plethysmography Status |
| `position`  | Body Position          |
| `PTT`       | Pulse Transit Time     |
| `pulse`     | Pulse                  |
| `r_r`      | RR interval            |


