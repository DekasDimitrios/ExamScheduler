schedule_errors([im204, im209, im210], [im212, im214, im216], [im217, im218], E). % E = 1

schedule_errors([im204, im210, im217], [im216, im212, im214], [im218, im209], E). % E = 1

schedule_errors([im204, im209, im210], [im212, im216, im218], [im214, im217], E). % E = 2

schedule_errors([im204, im209, im210], [im212, im216, im217], [im214, im218], E). % E = 3

schedule_errors([im204, im209, im210], [im212, im214, im217], [im216, im218], E). % E = 4

schedule_errors([im204, im209, im210], [im214, im217, im218], [im212, im216], E). % E = 5

schedule_errors([im204, im209, im217], [im212, im214, im218], [im210, im216], E). % E = 6

schedule_errors([im204, im209, im212], [im210, im216, im214], [im218, im217], E). % E = 0

score_schedule([im204,im209,im212],[im210,im214,im216],[im217,im218],S). % S = 600
