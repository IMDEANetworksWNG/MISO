import numpy as np
from gnuradio import gr
import time

class iq_file_source(gr.sync_block):
    def __init__(self, file_path="/home/imdea/Documents/RFNOC_ANTHONY/MATLAB/IQ_SAMPLES_MCS_1_5pk.txt"):
        gr.sync_block.__init__(self,
            name="iq_file_source",
            in_sig=None,
            out_sig=[np.complex64])

        self.file_path = file_path  # Guarda la ruta del archivo
        self.samples = self.load_samples()  # Carga las muestras
        self.idx = 0

    def load_samples(self):
        # Cargar las muestras I/Q desde el archivo binario
        with open(self.file_path, 'rb') as f:
            samples = np.fromfile(f, dtype=np.complex64)
        return samples

    def work(self, input_items, output_items):
        out = output_items[0]
        num_output_samples = len(out)
        num_remaining_samples = len(self.samples) - self.idx  # Muestras restantes
        num_samples_to_send = min(num_output_samples, num_remaining_samples)

        if num_samples_to_send > 0:
            # Enviar las muestras I/Q
            out[:num_samples_to_send] = self.samples[self.idx:self.idx + num_samples_to_send]
            self.idx += num_samples_to_send
        else:
            time.sleep(0.5)
            self.idx = 0
            return 0

        return num_samples_to_send

# Bloque de GNU Radio
class iq_file_source_block(gr.hier_block2):
    def __init__(self, file_path=""):
        gr.hier_block2.__init__(self,
            "iq_file_source_block",
            gr.io_signature(0, 0, 0),  # Sin entradas
            gr.io_signature(1, 1, gr.sizeof_gr_complex))  # Una salida compleja

        self.iq_source = iq_file_source(file_path)
        self.connect(self.iq_source, self)