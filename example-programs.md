# Programs

### Black

**Steps: 1**

| Step | State     |
| :--- | :-------- |
| 1    | `O O O O` |

### Blink

**Steps: 1**

| Step | State     |
| :--- | :-------- |
| 1    | `@ @ @ @` |

| Variation   | Parameters     |
| :---------- | :------------- |
| Strobe      | `b=0.5&a=0.75` |
| Short blink | `b=1&a=0.25`   |
| Long blink  | `b=4&a=0.75`   |

### Sweep

**Steps: number of LEDs**

| Step | State     |
| :--- | :-------- |
| 1    | `@ O O O` |
| 2    | `O @ O O` |
| 3    | `O O @ O` |
| 4    | `O O O @` |

| Variation  | Parameters             |
| :--------- | :--------------------- |
| Sweep on 4 | `b=4&a=0.125`          |
| Walk       | `b=1&a=1`              |
| Long walk  | `b={numberOfLeds}&a=1` |

### Fill

**Steps: 2 x  number of LEDs**

| Step | State     |
| :--- | :-------- |
| 1    | `@ O O O` |
| 2    | `@ @ O O` |
| 3    | `@ @ @ O` |
| 4    | `@ @ @ @` |
| 5    | `O @ @ @` |
| 6    | `O O @ @` |
| 7    | `O O O @` |
| 8    | `O O O O` |

### Alternate

**Steps: 2**

| Step | State     |
| :--- | :-------- |
| 1    | `@ @ O O` |
| 2    | `O O @ @` |
