## makeCacheMatrix creates a special matrix 
## that creates a list of 4 functions to:
# 1. set the values of the matrix
# 2. get the values of the matrix
# 3. set the inverse of the matrix
# 4. get the inverse of the matrix

makeCacheMatrix <- function(x = matrix()) {
  inv <- NULL
  set <- function(y) {
    x <<- y
    inv <<- NULL
  }
  get <- function() x
  setMatrixInverse <- function(mtrx) inv <<- mtrx
  getMatrixInverse <- function() inv
  list(set = set, get = get,
       setMatrixInverse = setMatrixInverse,
       getMatrixInverse = getMatrixInverse)
}


## cacheSolve function examines the special matrix returned from makeCacheMatrix
## if the inverse of this matrix is already present in memory (not NULL) then it
## returns the existing inverse of this matrix from memory with a message "getting cached data"
## else it computes the matrix inverse and stores in memory

cacheSolve <- function(x, ...) {
  ## Return a matrix that is the inverse of 'x'
  inv <- x$getMatrixInverse()
  if(!is.null(inv)) {
    message("getting cached data")
    return(inv)
  }
  data <- x$get()
  inv <- solve(data, ...)
  x$setMatrixInverse(inv)
  inv
}
