# alicat MFC 

MATLAB class to control Alicat MFCs over a USB port. 

# Usage

Create a MFC object:

```matlab
m = MFC;
```

Look at the values of the P term in the control loop:

```matlab
m.P
```

Set the value of the P term in the control loop to a new value:

```matlab
m.P = 1000;
```

Change the setpoint to 100mL/min

```matlab
m.set_point = 100;
```


# Installation 

Install using my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m')
install sg-s/alicat-mfc
install sg-s/srinivas.gs_mtools 
```

# License 

[GPL v3](http://gplv3.fsf.org/)