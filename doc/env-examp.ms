
.PP
The use of the primitives and operations defined above,
will now be illustrated by showing
how the environment and state are affected by
the following program fragment:
.DS
const ic := 3;
var   sv := 'abc';
var   y;
var   z := [10, 20, 30];
      y := z;
.DE
We assume that there exist, initially, an empty state S\d0\u
(S\d0\u \*(el STATE) and an empty environment E\d0\u
(E\d0\u \*(el ENVIRONMENT).
.IP 1)
Declare constant "ic".
A new INTEGER value 3 must be created and this must be associated with
the name "ic".
This is accomplished by E\d0\u.bind('c', a_integer(3)).
We will refer to the resulting state and environment as
E\d1\u and S\d1\u (= S\d0\u) respectively:
.DS L
---------- E1 ------         --------- S1 ---------
        ------------
ic --> | integer: 3 |
        ____________
.DE
.IP 2)
Declare and initialize variable "sv".
This is accomplished by E1.bind('sv', S1.extend(a_string('abc'))).
This gives environment and state E2 and S2:
.DS L
---------- E2 -------        ---------- S2 ------------
        ------------
ic --> | integer: 3 |
        ____________
                                        ---------------
sv ------------------------> locsv --> | string: 'abc' |
                                        _______________
.DE
.IP 3)
Declare the uninitialized variable "y" by
E2.bind('y', S2.extend(a_undefined)).
This gives environment and state E3 and S3:
.DS L
-------- E3 --------         ---------- S3 ------------
        ------------
ic --> | integer: 3 |
        ____________
                                        ---------------
sv ------------------------> locsv --> | string: 'abc' |
                                        _______________

                                        -----------
y  ------------------------> locy  --> | undefined |
                                        ___________
.DE
.IP 4)
Next, an instance of "array" is bound to variable "z".
The details of the creation of the array instance are not shown,
it is sufficient to know that the instance containes a number
of locations to hold the values of the respective array element.
.DS L
-------- E4 --------         ---------- S4 -----------------------
        ------------
ic --> | integer: 3 |
        ____________
                                        ---------------
sv ------------------------> locsv --> | string: 'abc' |
                                        _______________

                                        -----------
y  ------------------------> locy  --> | undefined |
                                        ___________

                                        --------------------------
z  ------------------------> locz  --> | array:                   |
                                       |           -------------  |
                                       | loc0 --> | integer: 10 | |
                                       |           -------------  |
                                       | loc1 --> | integer: 20 | |
                                       |           -------------  |
                                       | loc2 --> | integer: 30 | |
                                       |           _____________  |
                                       |                          |
                                        __________________________ 

.DE
.IP 5)
Finally, the assignment "y := z" is performed.
Note how the array instance becomes "shared", i.e.
becomes accessible via "y" and "z".
.DS L
-------- E5 --------         ---------- S5 -----------------------
        ------------
ic --> | integer: 3 |
        ____________
                                        ---------------
sv ------------------------> locsv --> | string: 'abc' |
                                        _______________

y  ------------------------> locy  -------------
                                                |
                                                V
                                        --------------------------
z  ------------------------> locz  --> | array:                   |
                                       |           -------------  |
                                       | loc0 --> | integer: 10 | |
                                       |           -------------  |
                                       | loc1 --> | integer: 20 | |
                                       |           -------------  |
                                       | loc2 --> | integer: 30 | |
                                       |           _____________  |
                                       |                          |
                                        __________________________ 

.DE
