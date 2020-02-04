sample_rate = 32768;
duration = 4;
nPartials = 32;
fundamental_frequency = 262;
decay_exponent = 1;

nSamples = duration * sample_rate;
amplitudes = (1:nPartials).^(-decay_exponent);
waveform = zeros(1,nSamples);

frequency_multiplier = ones(1,nSamples);
frequency_multiplier(round(1+nSamples/3):round(2*nSamples/3)) = ...
    logspace(log10(1),log10(2),(nSamples/3));
frequency_multiplier(round(1+2*nSamples/3):end) = 2;
phase_multiplier = cumsum(frequency_multiplier);

for odd_partial_index = 1:2:nPartials
    amplitude = amplitudes(odd_partial_index);
    frequency = fundamental_frequency * odd_partial_index;
    partial = amplitude .* cos(2*pi*frequency*phase_multiplier/sample_rate);
    waveform = waveform + partial;
end


for even_partial_index = 2:2:nPartials
    amplitude = amplitudes(even_partial_index);
    frequency = fundamental_frequency * even_partial_index;
    partial = amplitude .* cos(2*pi*frequency*phase_multiplier/sample_rate);
    waveform = waveform + partial;
end

sigmoid = 1./(1+exp(-(10*((1:nSamples)-nSamples/18)/sample_rate)));
reverse_sigmoid = sigmoid(end:-1:1);
waveform = waveform .* sigmoid .* reverse_sigmoid;
waveform = 0.1 * waveform.'/max(abs(waveform));
audiowrite('octave_glissando.wav',waveform,sample_rate);

%%
opts{1}.time.size = nSamples;
opts{1}.time.T = 2^10;
opts{1}.time.nFilters_per_octave = 24;
opts{1}.time.max_qualityfactor = 12;
opts{1}.time.max_scale = Inf;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [ ...
    13, 12+6*opts{1}.time.nFilters_per_octave];
archs = sc_setup(opts);

[S, U] = sc_propagate(waveform, archs);

%
scalogram = display_scalogram(U{1+1});
imagesc(log1p(0.001*scalogram));
colormap rev_magma;
axis off;