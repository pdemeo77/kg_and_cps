# Lab data generator — single source of truth for the cardiac datasets.
# Produces: clinical_history.csv, ecg_data.json, clinical_events.csv
# Run:  powershell -ExecutionPolicy Bypass -File .\generate_data.ps1
$ErrorActionPreference = 'Stop'
$lab = $PSScriptRoot
if (-not $lab) { $lab = Split-Path -Parent $MyInvocation.MyCommand.Path }

function WriteNoBom($path, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($path, $text, $enc)
}

# ---------- 20-patient roster (cardiac; clinically consistent) ----------
$roster = @(
  [pscustomobject]@{patient_id='P001';name='Maria Rossi';     age=68;sex='F';diagnoses='49436004;38341003';medications='Warfarin;Metoprolol';                   hr=142,96,110,88,128;  qt=380,372,376,384,368;rhythm='AFib';                sys=158;dia=95;primdx='49436004'}
  [pscustomobject]@{patient_id='P002';name='Giovanni Bianchi';age=72;sex='M';diagnoses='84114007;38341003';medications='Furosemide;Ramipril;Bisoprolol';         hr=76,82,74,88,70;     qt=380,386,378,390,376;rhythm='Sinus';              sys=138;dia=86;primdx='84114007'}
  [pscustomobject]@{patient_id='P003';name='Lucia Conti';     age=55;sex='F';diagnoses='22298006';          medications='Atorvastatin;Aspirin;Bisoprolol';         hr=70,74,68,80,66;     qt=372,376,370,380,368;rhythm='Sinus';              sys=128;dia=82;primdx='22298006'}
  [pscustomobject]@{patient_id='P004';name='Marco Ferrari';   age=61;sex='M';diagnoses='49436004;73211009';medications='Apixaban;Metformin';                       hr=88,104,95,86,110;   qt=384,388,386,382,390;rhythm='AFib';                sys=134;dia=88;primdx='49436004'}
  [pscustomobject]@{patient_id='P005';name='Giulia Romano';   age=70;sex='F';diagnoses='48694002;38341003';medications='Aspirin;Atorvastatin;Amlodipine';          hr=72,78,70,82,68;     qt=378,382,376,384,374;rhythm='Sinus';              sys=142;dia=90;primdx='48694002'}
  [pscustomobject]@{patient_id='P006';name='Paolo Greco';     age=59;sex='M';diagnoses='62709007';          medications='Amiodarone;Digoxin';                      hr=118,92,105,88,112;  qt=520,510,518,505,516;rhythm='Atrial fibrillation'; sys=130;dia=84;primdx='62709007'}
  [pscustomobject]@{patient_id='P007';name='Elena Marino';    age=77;sex='F';diagnoses='84114007;49436004';medications='Furosemide;Warfarin;Digoxin';             hr=112,90,105,96,108;  qt=402,396,404,398,406;rhythm='AFib';                sys=150;dia=92;primdx='84114007'}
  [pscustomobject]@{patient_id='P008';name='Roberto Costa';   age=64;sex='M';diagnoses='38341003';          medications='Ramipril;Amlodipine';                     hr=74,80,72,78,70;     qt=376,380,374,378,372;rhythm='Sinus';              sys=144;dia=91;primdx='38341003'}
  [pscustomobject]@{patient_id='P009';name='Anna Bruno';      age=80;sex='F';diagnoses='49436004';          medications='Warfarin;Amiodarone';                     hr=131,105,122,96,115; qt=460,456,462,452,458;rhythm='AFib';                sys=152;dia=88;primdx='49436004'}
  [pscustomobject]@{patient_id='P010';name='Francesco Russo'; age=50;sex='M';diagnoses='73211009';          medications='Metformin;Aspirin';                       hr=76,82,74,80,72;     qt=380,384,378,382,376;rhythm='Sinus';              sys=126;dia=80;primdx='73211009'}
  [pscustomobject]@{patient_id='P011';name='Maria Galli';     age=66;sex='F';diagnoses='22298006;84114007';medications='Bisoprolol;Ramipril;Atorvastatin';        hr=74,80,72,78,84;     qt=376,380,374,378,384;rhythm='Sinus';              sys=136;dia=84;primdx='22298006'}
  [pscustomobject]@{patient_id='P012';name='Luigi Conti';     age=73;sex='M';diagnoses='49436004';          medications='Digoxin;Apixaban';                        hr=86,92,84,90,80;     qt=438,440,436,442,438;rhythm='AFib';                sys=140;dia=86;primdx='49436004'}
  [pscustomobject]@{patient_id='P013';name='Sofia Bianchi';   age=58;sex='F';diagnoses='38341003;73211009';medications='Lisinopril;Metformin';                    hr=78,84,76,82,74;     qt=382,386,380,384,378;rhythm='Sinus';              sys=148;dia=94;primdx='38341003'}
  [pscustomobject]@{patient_id='P014';name='Antonio Greco';   age=69;sex='M';diagnoses='48694002;49436004';medications='Aspirin;Bisoprolol;Warfarin';             hr=116,98,108,92,112;  qt=392,388,394,386,392;rhythm='AFib';                sys=138;dia=82;primdx='48694002'}
  [pscustomobject]@{patient_id='P015';name='Luca Costa';      age=75;sex='M';diagnoses='84114007;73211009';medications='Spironolactone;Furosemide;Ramipril';      hr=80,86,78,84,76;     qt=382,386,380,384,378;rhythm='Sinus';              sys=146;dia=90;primdx='84114007'}
  [pscustomobject]@{patient_id='P016';name='Giuseppa Marino'; age=62;sex='F';diagnoses='62709007';          medications='Metoprolol';                              hr=82,88,80,86,78;     qt=384,388,382,386,380;rhythm='Sinus';              sys=122;dia=78;primdx='62709007'}
  [pscustomobject]@{patient_id='P017';name='Giovanni Ferrari';age=81;sex='M';diagnoses='49436004;38341003';medications='Warfarin;Lisinopril';                     hr=88,94,86,92,84;     qt=428,430,426,432,428;rhythm='AFib';                sys=156;dia=92;primdx='49436004'}
  [pscustomobject]@{patient_id='P018';name='Lucia Romano';    age=54;sex='F';diagnoses='22298006';          medications='Aspirin;Atorvastatin;Metoprolol';         hr=72,78,70,76,68;     qt=374,378,372,376,370;rhythm='Sinus';              sys=124;dia=80;primdx='22298006'}
  [pscustomobject]@{patient_id='P019';name='Paolo Russo';     age=71;sex='M';diagnoses='84114007;73211009';medications='Bisoprolol;Furosemide;Metformin';         hr=78,84,76,82,86;     qt=380,384,378,382,386;rhythm='Sinus';              sys=130;dia=84;primdx='84114007'}
  [pscustomobject]@{patient_id='P020';name='Anna Galli';      age=60;sex='F';diagnoses='38341003;49436004';medications='Apixaban;Diltiazem';                      hr=84,90,82,88,94;     qt=386,390,384,388,392;rhythm='AFib';                sys=150;dia=96;primdx='38341003'}
)

# ---------- 1) clinical_history.csv ----------
$hist = $roster | Select-Object patient_id,name,age,sex,diagnoses,medications
$csvHist = ($hist | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
WriteNoBom "$lab\clinical_history.csv" ($csvHist + "`r`n")

# ---------- 2) ecg_data.json (5 records / patient = 100) ----------
$times = @('08:05:00','12:20:00','16:40:00','09:15:00','20:30:00')
$recs = @(); $n = 1
foreach ($r in $roster) {
  for ($k = 0; $k -lt 5; $k++) {
    $recs += [pscustomobject]@{
      record_id  = ('ECG-{0:D3}' -f $n)
      patient_id = $r.patient_id
      timestamp  = ('2024-03-{0:D2}T{1}' -f (9 + $k), $times[$k])
      heart_rate = [int]$r.hr[$k]
      qrs_ms     = 88 + ($k * 4)
      qt_ms      = [int]$r.qt[$k]
      rhythm     = $r.rhythm
    }
    $n++
  }
}
$json = $recs | ConvertTo-Json -Depth 5
WriteNoBom "$lab\ecg_data.json" ($json + "`n")

# ---------- 3) clinical_events.csv (50) ----------
function Sev($type, $v) {
  if ($type -eq '8480-6') { if ($v -ge 160) {'severe'} elseif ($v -ge 130) {'moderate'} else {'mild'} }
  else                    { if ($v -ge 100) {'severe'} elseif ($v -ge 80)  {'moderate'} else {'mild'} }
}
$rows = New-Object System.Collections.ArrayList
$eid = 1
foreach ($i in 0..($roster.Count - 1)) {
  $r = $roster[$i]
  $d = if ($i % 2 -eq 0) { '2024-03-09' } else { '2024-03-12' }
  [void]$rows.Add([pscustomobject]@{event_id=('E{0:D3}' -f $eid);patient_id=$r.patient_id;event_date=$d;event_type='lab_test';concept_code='8480-6';value=$r.sys;unit='mmHg';severity=(Sev '8480-6' $r.sys)}); $eid++
  [void]$rows.Add([pscustomobject]@{event_id=('E{0:D3}' -f $eid);patient_id=$r.patient_id;event_date=$d;event_type='lab_test';concept_code='8462-4';value=$r.dia;unit='mmHg';severity=(Sev '8462-4' $r.dia)}); $eid++
}
$extra = @(
  ,@('E041','P001','2024-02-20','admission','49436004','','','severe')
  ,@('E042','P003','2024-02-15','admission','22298006','','','severe')
  ,@('E043','P006','2024-03-05','medication_change','Amiodarone','','','')
  ,@('E044','P009','2024-02-28','admission','49436004','','','severe')
  ,@('E045','P011','2024-02-10','admission','22298006','','','severe')
  ,@('E046','P014','2024-03-01','medication_change','Warfarin','','','')
  ,@('E047','P015','2024-03-03','medication_change','Spironolactone','','','')
  ,@('E048','P007','2024-02-18','admission','84114007','','','severe')
  ,@('E049','P018','2024-02-22','admission','22298006','','','severe')
  ,@('E050','P020','2024-03-08','medication_change','Apixaban','','','')
)
foreach ($e in $extra) {
  [void]$rows.Add([pscustomobject]@{event_id=$e[0];patient_id=$e[1];event_date=$e[2];event_type=$e[3];concept_code=$e[4];value=$e[5];unit=$e[6];severity=$e[7]})
}
$csvEv = ($rows | Sort-Object event_id | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
WriteNoBom "$lab\clinical_events.csv" ($csvEv + "`r`n")

# ---------- summary ----------
"clinical_history.csv : {0} patients" -f $roster.Count
"ecg_data.json        : {0} records ({1} patients x 5)" -f $recs.Count, $roster.Count
"clinical_events.csv  : {0} events ({1} labs + {2} other)" -f $rows.Count, ($roster.Count*2), $extra.Count
