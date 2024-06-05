#!/bin/bash 

array1=(element1 element2 element3)
array2=(apple banana cherry)

for (( i=0; i<${#array1}; i++ )); do
  # Access elements using the same index
  echo "${array1[$i]}: ${array2[$i]}"
done