%*******************************************************************************
% Copyright (c) 2020-2021
% Author(s): Volker Fischer
%*******************************************************************************
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
%*******************************************************************************

function [x, pad] = signalsandsettings(is_called_from_other_function)

% special case: if this function is called, we assume drumtrigger should be called
if ~exist('is_called_from_other_function', 'var')
  drumtrigger;
  return;
end

padtype = 'pd120'; % default

% load test data

%x = audioread("signals/teensy4_0_noise_test.wav");x=(x-mean(x))*4;padtype = 'pd80r';
%x = audioread("signals/teensy4_0_pd80r.wav");x=(x-mean(x))*4;padtype = 'pd80r';%x = x(1:390000, :);%
%x = audioread("signals/esp32_pd120.wav");x=x/8;
%x = audioread("signals/esp32_pd8.wav");x=x/8;padtype = 'pd8';
%x = audioread("signals/pd120_pos_sense.wav");%x=x(10600:15000);%x = x(2900:10000, :);%x = x(55400:58000, :);%
%x = audioread("signals/pd120_pos_sense2.wav");
%x = audioread("signals/pd120_single_hits.wav");
%x = audioread("signals/pd120_roll.wav");%x = x(1:20000, :);%x = x(292410:294749, :);%x = x(311500:317600, :);
x = audioread("signals/pd120_middle_velocity.wav");
%x = audioread("signals/pd120_hot_spot.wav");
%x = audioread("signals/pd120_rimshot.wav");%x=x(7000:15000,:);%x = x(1:100000, :);%x = x(168000:171000, :);%x = x(1:34000, :);%
%x = audioread("signals/pd120_rimshot_hardsoft.wav");
%x=audioread("signals/pd120_middle_velocity.wav");x=[x;audioread("signals/pd120_pos_sense2.wav")];x=[x;audioread("signals/pd120_hot_spot.wav")];
%x = audioread("signals/pd80r.wav");x=x(:,1);padtype='pd80r';x = x(1:265000, :);%x = x(264000:320000, :);%
%x = audioread("signals/pd80r_rimshot_issue.wav");padtype='pd80r';
%x = audioread("signals/pd6.wav");
%x = audioread("signals/pd8.wav");padtype = 'pd8';%x = x(1:300000, :);%x = x(420000:470000, :);%x = x(1:100000, :);
%x = audioread("signals/pd8_rimshot.wav");padtype = 'pd8';
%x = audioread("signals/cy6.wav");padtype = 'cy6';%x = x(480000:590000, :);%x = x(250000:450000, :);%x = x(1:150000, :);
%x = audioread("signals/cy8.wav");padtype = 'cy8';%x = x(1:200000, :);
%x = audioread("signals/kd8.wav");
%x = audioread("signals/kd7.wav");padtype = 'kd7';%x = x(1:170000, :);
%x = audioread("signals/kd7_hard_hits.wav");padtype = 'kd7';x = x(1:3000, :);
%x = audioread("signals/tp80.wav");padtype = 'tp80';
%x = audioread("signals/vh12.wav");padtype = 'vh12';%x = x(900000:end, :);%x = x(376000:420000, :);%x = x(1:140000, :);

% scale to the ESP32 input range to match the signal level of the ESP32
x = x * 25000;



% Clipping experiments ---------------------------------------------------------
%x = x(27515:27530); % select the main peak of one loud hit
x = x(27500:27550);
m = max(x); % store the original maximum value for later evaluation

c = 3000;%2500; % select how much shall be clipped
x_c = min(max(x, -c), c); % here the signal is clipped


alpha = 2000 / 8000;
x_low = filter(alpha, [1, alpha - 1], x_c) * 1.7;%1.4;
x_low = circshift(x_low, -2);

n = length(find(x_c == c)); % find how many samples are clipped
figure;plot([x, x_c, x_low], '*-');title(['m: ' num2str(m) ' / n: ' num2str(n)]);

y = m - c; % how much is clipped
x = n;
x
y


%x = [9,    9,    8,    6,    4,    4,   4,   3,   3,   2,   2,   2,   2];
%y = [2932, 2632, 2432, 1432, 1032, 632, 432, 332, 282, 231, 182, 142, 82];
%figure; plot(x, y)

return



% pad PRESET settings first, then overwrite these with pad specific properties
pad.threshold_db              = 17;
pad.mask_time_ms              = 6;
pad.first_peak_diff_thresh_db = 8;
pad.mask_time_decay_fact_db   = 15;
pad.scan_time_ms              = 2.5;
pad.pre_scan_time_ms          = 3;
pad.decay_est_delay_ms        = 8;
pad.decay_est_len_ms          = 3;
pad.decay_est_fact_db         = 16;
pad.decay_fact_db             = 1;
pad.decay_len_ms1             = 0; % not used
pad.decay_len_ms2             = 250;
pad.decay_len_ms3             = 0; % not used
pad.decay_grad_fact1          = 200;
pad.decay_grad_fact2          = 200;
pad.decay_grad_fact3          = 200;
pad.pos_low_pass_cutoff       = 150; % Hz
pad.pos_invert                = false;
pad.rim_shot_window_len_ms    = 3.5;
pad.rim_low_pass_iir_alpha    = 700;

switch padtype
  case 'pd120'
    % note: the PRESET settings are from the PD120 pad
  case 'pd80r'
    pad.scan_time_ms       = 3;
    pad.decay_len_ms2      = 75;
    pad.decay_grad_fact2   = 300;
    pad.decay_len_ms3      = 300;
    pad.decay_grad_fact3   = 100;
  case 'pd8'
    pad.scan_time_ms       = 1.3;
    pad.decay_est_delay_ms = 6;
    pad.mask_time_ms       = 7;
    pad.decay_fact_db      = 5;
    pad.decay_len_ms2      = 30;
    pad.decay_grad_fact2   = 600;
    pad.decay_len_ms3      = 150;
    pad.decay_grad_fact3   = 120;
  case 'tp80'
    pad.scan_time_ms       = 2.75;
    pad.decay_est_delay_ms = 11;
    pad.decay_len_ms2      = 60;
    pad.decay_grad_fact2   = 400;
    pad.decay_len_ms3      = 700;
    pad.decay_grad_fact3   = 60;
    pad.pos_invert         = true;
  case 'vh12'
% TODO if the Hi-Hat is open just a little bit, we get double triggers
    pad.threshold_db       = 16;
    pad.scan_time_ms       = 4;
    pad.decay_est_delay_ms = 9;
    pad.decay_fact_db      = 5;
    pad.decay_len_ms2      = 27;
    pad.decay_grad_fact2   = 700;
    pad.decay_len_ms3      = 600; % must be long because of open Hi-Hat ringing
    pad.decay_grad_fact3   = 75;
  case 'kd7'
    pad.scan_time_ms       = 2;
    pad.decay_est_delay_ms = 8;
    pad.decay_fact_db      = 5;
    pad.decay_len_ms1      = 4;
    pad.decay_grad_fact1   = 30;
    pad.decay_len_ms2      = 30;
    pad.decay_grad_fact2   = 450;
    pad.decay_len_ms3      = 500;
    pad.decay_grad_fact3   = 45;
  case 'cy6'
    pad.scan_time_ms       = 6;
    pad.decay_len_ms2      = 150;
    pad.decay_grad_fact2   = 120;
    pad.decay_len_ms3      = 450;
    pad.decay_grad_fact3   = 30;
  case 'cy8'
    pad.scan_time_ms       = 6;
    pad.decay_len_ms1      = 10;
    pad.decay_grad_fact1   = 10;
    pad.decay_len_ms2      = 100;
    pad.decay_grad_fact2   = 200;
    pad.decay_len_ms3      = 450;
    pad.decay_grad_fact3   = 30;
end

end


