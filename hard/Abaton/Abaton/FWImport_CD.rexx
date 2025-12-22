/* Insert image from Abaton scanner into FinalWriter work processor. */

address COMMAND "work:abaton/scan/scan TO RAM:T/image.iff Area=CD Sensitivity=8 Invert"
address FINALW.1 'ImportPrefs LineWt=.5 Linked=No'
address FINALW.1 'InsertImage RAM:T/image.iff Position 1 -1 -1 3.5 2.0'
address FINALW.1 Redraw
address COMMAND "delete RAM:T/image.iff"
