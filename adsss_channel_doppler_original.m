% doppler - Compute doppler effect for moving observer
clear all; help doppler; % Clear memory; print header
%@ Initialize variables
kSource = 2*pi; % Wave number of the source (m^-1)
wSource = 2*pi; % Frequency (omega) of source (Hz)
cWave = wSource/kSource; % Speed of the wave
fprintf('Speed of the wave is %g m/s\n',cWave);
vObs = input('Enter observer speed (m/s): ');
t = 0; % Initial time
tIncrement = 0.03; % Time increment between steps
%@ Set up graphics
clf; figure(gcf); % Clear figure; Bring figure window forward
xMax = 5; % Maximum value of x for plots
NPoints = 100; % Number of points to plot when drawing the wave
for i=1:NPoints % Compute values of x for plot
 x(i) = (i-1)/(NPoints-1)*xMax;
end
xObs0 = xMax/2; % Initial location of observer (center of plot)
xObs = xObs0; % Location of observer
%@ Loop over the number of steps, periodically plotting a snapshot
NSteps = 100; % Number of steps
ShotInterval = 10; % Snapshot plotted once every 10 steps
for iStep=1:NSteps
 %@ Compute the wave displacement at location of moving observer
 zObs = sin(kSource*xObs - wSource*t);
 %@ Compute the wave displacement at location of stationary observer
 zStat = sin(kSource*xObs0 - wSource*t);
 
 %@ If it is time to plot a snapshot then,
 if( rem(iStep,ShotInterval) == 1 )
 %@ Compute and plot the wave displacement vs x for the current time
 z = sin(kSource*x - wSource*t);
 plot(x,z,'y-');
 axis([0, xMax, -1, 1]); % Set the axis limits
 xlabel(sprintf('Position (m) t = %g s',t)); % X-axis label
 ylabel('Wave displacement'); % Y-axis label
 title('Observers at positions marked with vertical lines');
 hold on;
 %@ Mark the location of each observer with a vertical bar
 plot([xObs xObs],[-1 1],'r:');
 plot([xObs0 xObs0],[-1 1],'b:');
 %@ Mark the wave amplitude at the moving and stationary observers
 plot(xObs,zObs,'r*');
 plot(xObs0,zStat,'bx');
%@ Write text string on graph (indicating wave direction)
text(1.0+cWave*t,0.5,'Wave moving this way =>');
 drawnow; % Draw the graph
 hold off;
 end
 
 %@ Record the time and wave amplitude at each observer
 tPlot(iStep) = t; % Record time for final plot
 zObsPlot(iStep) = zObs; % Record zObs for final plot
 zStatPlot(iStep) = zStat; % Record zStat for final plot
 
 %@ Increment the time and the position of the moving observer
 t = t + tIncrement; % Update time
 xObs = xObs + vObs*tIncrement; % Update moving observer position
 
end
title('*** STRIKE ANY KEY TO CONTINUE ***');
pause; % Pause before drawing the next plot
%@ Plot wave displacement versus time as seen by each observer
hold off; % Turn off the plotting hold
plot(tPlot,zObsPlot,'r*',tPlot,zStatPlot,'bx')
xlabel('Time (s)');
ylabel('Wave displacement');
title('Moving (*) and stationary (x) observers');