import numpy
import pandas

GRAVITY = 9.81

ACC_NOISE_STD = 0.08
GYRO_NOISE_STD = 0.015

ACC_BIAS_CONST = numpy.array([0.15, -0.1, 0.2])
GYRO_BIAS_CONST = numpy.array([0.02, -0.015, 0.005])

def generator(duration=20, samplingRate=100, seed=42):
    numpy.random.seed(seed)

    deltatime = 1.0 / samplingRate
    time = numpy.arange(0, duration, deltatime)
    samples = len(time)

    # => Ground-Truth
    # Simulate a gentle oscillation in roll and pitch, and a steady turn in yaw..
    trueRoll = 0.2 * numpy.sin(2*numpy.pi*0.1*time)
    truePitch = 0.15 * numpy.cos(2*numpy.pi*0.15*time)
    trueYaw = 0.1 * time

    # ==> True-Angular-Velocity (rad/s) -- Derived from Euler's Rate Equation (Simplified)
    # Under small-angle assumptions, angular rates are close to derivatives of Euler angles..
    trueGyroX = numpy.gradient(trueRoll, deltatime)
    trueGyroY = numpy.gradient(truePitch, deltatime)
    trueGyroZ = numpy.gradient(trueYaw, deltatime)

    # ==> True-Linear-Acceleration (Excluding-Gravity)
    trueAccX = 0.5 * numpy.sin(2*numpy.pi*0.2*time)
    trueAccY = 0.3 * numpy.cos(2*numpy.pi*0.2*time)
    trueAccZ = numpy.zeros(samples)

    # => Gravity-Vector-Projection
    gravityX = -GRAVITY * numpy.sin(truePitch)
    gravityY = GRAVITY * numpy.cos(truePitch) * numpy.sin(trueRoll)
    gravityZ = GRAVITY * numpy.cos(truePitch) * numpy.cos(trueRoll)

    idealAccX = trueAccX + gravityX
    idealAccY = trueAccY + gravityY
    idealAccZ = trueAccZ + gravityZ

    # => Noise-And-Bias
    driftAcc = numpy.cumsum(numpy.random.normal(0, 0.001, (samples, 3)), axis=0)
    driftGyro = numpy.cumsum(numpy.random.normal(0, 0.0001, (samples, 3)), axis=0)

    accX = idealAccX + ACC_BIAS_CONST[0] + driftAcc[:, 0] + numpy.random.normal(0, ACC_NOISE_STD, samples)
    accY = idealAccY + ACC_BIAS_CONST[1] + driftAcc[:, 1] + numpy.random.normal(0, ACC_NOISE_STD, samples)
    accZ = idealAccZ + ACC_BIAS_CONST[2] + driftAcc[:, 2] + numpy.random.normal(0, ACC_NOISE_STD, samples)

    gyroX = trueGyroX + GYRO_BIAS_CONST[0] + driftGyro[:, 0] + numpy.random.normal(0, GYRO_NOISE_STD, samples)
    gyroY = trueGyroY + GYRO_BIAS_CONST[1] + driftGyro[:, 1] + numpy.random.normal(0, GYRO_NOISE_STD, samples)
    gyroZ = trueGyroZ + GYRO_BIAS_CONST[2] + driftGyro[:, 2] + numpy.random.normal(0, GYRO_NOISE_STD, samples)

    # => Data-Frame

    data = pandas.DataFrame({
        "Time": time,

        "True-Roll": trueRoll,
        "True-Pitch": truePitch,
        "True-Yaw": trueYaw,

        "Acc-X": accX,
        "Acc-Y": accY,
        "Acc-Z": accZ,
        "Gyro-X": gyroX,
        "Gyro-Y": gyroY,
        "Gyro-Z": gyroZ,

        "Acc-X-True": idealAccX,
        "Acc-Y-True": idealAccY,
        "Acc-Z-True": idealAccZ,
        "Gyro-X-True": trueGyroX,
        "Gyro-Y-True": trueGyroY,
        "Gyro-Z-True": trueGyroZ,
        })

    return data

dataframe = generator(duration=15, samplingRate=100)
dataframe.to_csv('Synthetic-MPU6050.csv', index=False)
