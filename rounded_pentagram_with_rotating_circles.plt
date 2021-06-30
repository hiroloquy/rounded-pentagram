reset
set angle degrees

#=================== Parameter ====================
# Parameters in drawing
psPoint = 2         # ps = point size
lwCircle = 2        # lw = line width
lwCursor  =2
lwTrajectory = 2
lcCursor = -1       # lc = line color
lcPoint = 6
lcCircle1 = 2
lcCircle2 = 4
numPNG = 0
LOOP = 3

DEG_DIV = 1.0           # Resolution of degree, increase by 1/DEG_DIV
roundNum = 2
plotRange = 10          # Set the range of x/y axis [-plotRange:plotRange]
offsetXaxisCircle = -6.5    # Offset of the center of circles plotting a curve
offsetYaxisCircle = -6.5

# Select terminal type
qtMode = 0     # ==1: qt (simulator) / !=1: png (output images for making video)
print sprintf("[MODE] %s", (qtMode==1 ? 'Simulate in Qt window' :'Output PNG images'))

#=================== Function ====================
# Parametric equations of a curve
x(t) = 2*sin(2*t)-cos(3*t)
y(t) = sin(3*t)-2*cos(2*t)

# Show the value of the parameter t
showT(t) = sprintf("{/:Italic t} = %3.1f deg", t)

#=================== Setting ====================
if(qtMode==1){
    set term qt size 720, 720 font 'Times'
} else {
    set term pngcairo size 720, 720 font 'Times'
    folderName = 'png_with_circles'
    system sprintf('mkdir %s', folderName)
}

unset key
set grid
set size ratio -1
set xlabel '{/:Italic x}' font ', 20'
set ylabel '{/:Italic y}' font ', 20'
set tics font ', 18'
 
# Round off to the i decimal place.
round(x, i) = 1 / (10.**(i+1)) * floor(x * (10.**(i+1)) + 0.5)
 
#=================== Calculation ====================
# Output: "draw_trajectory.txt" is need for plotting the curve.
dataTrajectory = 'draw_trajectory.txt'
print sprintf('Start outputting %s ...', dataTrajectory)
set print dataTrajectory

# Write items and parameters in outputfile
print sprintf("# %s", dataTrajectory)
print sprintf('# DEG_DIV=%d', DEG_DIV)
print '# t / x / y'
 
# Calculate and output the trajectory of the curve
do for[i=0:360*DEG_DIV:1]{
    t = i/DEG_DIV
    print round(t, roundNum), round(x(t), roundNum), round(y(t), roundNum)
}

unset print 
print sprintf('Finish!')

#=================== Plot ====================
if(qtMode == 1) {
    print "Start simulation"
} else {
    print sprintf('Start outputting %d images ...', LOOP*(1+360*DEG_DIV))
}

end(loop, i) =  (loop>0) ? 360*DEG_DIV : i

do for [n=0:LOOP-1:1]{
    do for [i=0:360*DEG_DIV:1]{
        if(qtMode != 1) {
            set output sprintf("%s/img_%04d.png", folderName, numPNG)
            numPNG = numPNG + 1
        }

        # Get the value of time from either of txt files
        set yrange [*:*]    # This command enables to remove restrictions on the range of the stats command.
        stats dataTrajectory using 1 every ::i::i nooutput
        theta = STATS_max
        set title showT(theta) left offset screen -0.07, -0.01 font ', 20'

        # x方向を描く円たち（y軸上に位置する）
        # x(t) = 2*sin(2*t)-cos(3*t)
        cx1_x =    0 + 2*sin(2*theta)
        cx1_y = offsetXaxisCircle + 2*cos(2*theta)
        cx2_x = cx1_x - cos(3*theta)
        cx2_y = cx1_y - sin(3*theta)
        set object 1 circle at 0, offsetXaxisCircle size 2 fs empty border lt lcCircle1 lw lwCircle
        set object 2 circle at cx1_x, cx1_y size 1 fs empty border lt lcCircle2 lw lwCircle
        set arrow 1 nohead from 0, offsetXaxisCircle to cx1_x, cx1_y lt lcCircle1 lw lwCircle
        set arrow 2 nohead from cx1_x, cx1_y to cx2_x, cx2_y lt lcCircle2 lw lwCircle
        set object 3 circle at cx1_x, cx1_y size 0.1 fs solid fc lt lcCircle1 lw lwCircle front
        set object 4 circle at cx2_x, cx2_y size 0.1 fs solid fc lt lcCircle2 lw lwCircle front
        set arrow 3 nohead from cx2_x, cx2_y to cx2_x, plotRange lt lcCursor lw lwCursor
        # set arrow 3 nohead from cx2_x, cx2_y to x(theta), y(theta) lt lcCursor lw lwCursor
        
        # y(t) = sin(3*t)-2*cos(2*t)
        cy1_x = offsetYaxisCircle + cos(3*theta)
        cy1_y =    0 + sin(3*theta)
        cy2_x = cy1_x - 2*sin(2*theta)
        cy2_y = cy1_y - 2*cos(2*theta)
        set object 5 circle at offsetYaxisCircle, 0 size 1 fs empty border lt lcCircle1 lw lwCircle 
        set object 6 circle at cy1_x, cy1_y size 2 fs empty border lt lcCircle2 lw lwCircle
        set arrow 4 nohead from offsetYaxisCircle, 0 to cy1_x, cy1_y lt lcCircle1 lw lwCircle
        set arrow 5 nohead from cy1_x, cy1_y to cy2_x, cy2_y lt lcCircle2 lw lwCircle
        set object 7 circle at cy1_x, cy1_y size 0.1 fs solid fc lt lcCircle1 lw lwCircle front
        set object 8 circle at cy2_x, cy2_y size 0.1 fs solid fc lt lcCircle2 lw lwCircle front
        set arrow 6 nohead from cy2_x, cy2_y to plotRange, cy2_y lt lcCursor lw lwCursor
        # set arrow 6 nohead from cy2_x, cy2_y to x(theta), y(theta) lt lcCursor lw lwCursor
        
        plot[-plotRange:plotRange][-plotRange:plotRange] \
            dataTrajectory using 2:3 every ::i::i with p ps psPoint pt 7 lc lcPoint, \
            dataTrajectory using 2:3 every ::0::end(n, i) with line lw lwTrajectory lc lcPoint

        if(qtMode == 1) {    
            if((n==0 && i==0) || n==LOOP-1 && i==360*DEG_DIV) {
                pause 2     # Wait a few seconds
            }
            pause 0.001     # Adjust the drawing speed
        } else {
            set out # terminal pngcairo
        }
    }
}

# Output the curve
set term pngcairo size 720, 720 font 'Times'
set output "trajectory_plot_with_circles.png"
plot[-plotRange:plotRange][-plotRange:plotRange] \
    dataTrajectory using 2:3 every ::360*DEG_DIV::360*DEG_DIV with p ps psPoint pt 7 lc lcPoint, \
    dataTrajectory using 2:3 every ::0::360*DEG_DIV with line lw lwTrajectory lc lcPoint
set out
print sprintf('Finish this program')
