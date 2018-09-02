import math

sensor_capacitor = 100e-9
overflow_ratio = 0.245
time_to_r_constant = math.log(1 - overflow_ratio)

def time_to_resistance(time, capacitance):
    return -time / (capacitance * time_to_r_constant)

def resistance_to_celsius(resistance):
    ln_r_rref = math.log(resistance / 150000)
    kelvin = 1 / ( 3.354016e-3 + ( 2.367720e-4 * ln_r_rref ) + ( 3.585140e-6 * ( ln_r_rref ** 2 ) ) + ( 1.255349e-7 * ( ln_r_rref ** 3 ) ) )
    return kelvin - 273.15

def reading_to_celsius(time):
    return resistance_to_celsius(time_to_resistance(time, sensor_capacitor))
