# Coarse
xc = np.arange(5)
yc = np.arange(7)
zc = np.arange(10)
XC, YC, ZC = np.meshgrid(xc, yc, zc)

# Fine
inc = 0.1
xf = np.arange(0, xc.max() + inc, inc)
yf = np.arange(0, yc.max() + inc, inc)
zf = np.arange(0, zc.max() + inc, inc)
XF, YF, ZF = np.meshgrid(xf, yf, zf)

# Data
VC = np.random.random(XC.shape) * 100

# Interpolate
points = (XC.flatten(), YC.flatten(), ZC.flatten())
values = VC.flatten()
fpoints = (XF.flatten(), YF.flatten(), ZF.flatten())
VF = griddata(points, values, fpoints, method='linear')
VF = np.reshape(VF, XF.shape)

zci = 4
zfi = zf.tolist().index(zc[zci])
figure()
pcolormesh(XF[..., zfi], YF[..., zfi], VF[..., zfi])
scatter(XC[..., zci].flatten(), YC[..., zci].flatten(), c=VC[..., zci].flatten())
colorbar()

