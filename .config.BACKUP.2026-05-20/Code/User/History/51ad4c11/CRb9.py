def fibonacci_sequence_validation(input_number):
    # Validación del número dado
    if not isinstance(input_number, int) or input_number < 0:
        raise ValueError("El número debe ser un entero positivo")
    
    # Verificar si el número está en la secuencia Fibonacci
    fib_numbers = [0, 1]
    while fib_numbers[-1] <= input_number and fib_numbers[-2] > 0:
        next_fib = fib_numbers[-1] + fib_numbers[-2]
        if next_fib <= input_number:
            fib_numbers.append(next_fib)
    
    # Si el número no está en la secuencia, devolver los más cercanos
    closest_fibs = []
    for i in range(len(fib_numbers)):
        current = fib_numbers[i]
        
        if abs(input_number - current) < 0.1:
            return input_number, f"El número {input_number} ya está en la secuencia Fibonacci"
    
    # Si el número no existe en la secuencia, devolver los más cercanos
    closest_fibs = []
    for i in range(len(fib_numbers)):
        current = fib_numbers[i]
        
        if abs(input_number - current) < 0.1:
            return input_number, f"El número {input_number} ya está en la secuencia Fibonacci"

    # Si no existe en la secuencia, devolver los más
