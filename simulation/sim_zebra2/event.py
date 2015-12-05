class Event(object):
    def __init__(self, ts=None, reg=None, pos=None, bit=None):
        # This is in FPGA counts
        self.ts = ts
        # This is a dict reg name -> value
        self.reg = reg or {}
        # These are dicts bus index -> value
        self.pos = pos or {}
        self.bit = bit or {}