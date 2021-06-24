reset
set angle degrees

#=================== Parameter ====================
# Parameters in drawing
psJoint = 1.5       # ps = point size
psDrop = 2
lwLink = 3          # lw = line width
lwTrajectory = 2
lcLink = -1
lcDrop = 6
numPNG = 0
LOOP = 3

DEG_DIV = 1.0     # Resolution of degree, increase by 1/DEG_DIV
roundNum = 2

# Select terminal type
qtMode = 1     # ==1: qt (simulator) / !=1: png (output images for making video)
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
    folderName = 'png'
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
    print sprintf('Start outputting %d images ...', 2+360*DEG_DIV*LOOP)
}

plotRange = 4
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

        plot[-plotRange:plotRange][-plotRange:plotRange] \
            dataTrajectory using 2:3 every ::i::i with p ps psDrop pt 7 lc lcDrop, \
            dataTrajectory using 2:3 every ::0::end(n, i) with line lw lwTrajectory lc lcDrop

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
set output "trajectory_plot.png"
plot[-plotRange:plotRange][-plotRange:plotRange] \
    dataTrajectory using 2:3 every ::0::360*DEG_DIV with line lw lwTrajectory lc lcDrop
set out
print sprintf('Finish this program')
