function lab_1()
    
    % Отладочный режим
    DEBUG = 0;
    
    % Если 0, решается задача мимнимизации, иначе - максимизации
    MAXIMIZE = 0;

    % Матрица стоимостей
    C = [ 10   4   9   8   5;
           9   3   5   7   8;
           2   5   8  10   5;
           4   5   7   9   3;
           8   7  10   9   6];
    
    % Размер матрицы стоимостей
    n = size(C, 1);
    
    % Копия матрицы стоимостей для операций
    Cm = C;
    
    % Координаты СНН
    independent_zeros = zeros(1, n);        
    
    % Первоначальная печать матрицы стоимостей
    fprintf("\n");
    print_Cm(Cm, independent_zeros);
        
    % В случае задачи макисимизации вычитаем элементы из максимума столбца
    if MAXIMIZE ~= 0
        column_max = max(Cm);
        for i = 1:n
            for j = 1:n
                Cm(i, j) = column_max(j) - Cm(i, j);
            end
        end
    end
        
    % В каждом столбце вычитаем минимум этого столбца
    column_min = min(Cm);
    for i = 1:n
        for j = 1:n
            Cm(i, j) = Cm(i, j) - column_min(j);
        end
    end
    
    % В каждой строке вычитаем минимум этой строки
    for i = 1:n
        minimal = min(Cm(i, :));
        for j = 1:n
            Cm(i, j) = Cm(i, j) - minimal;
        end
    end
    
    % Строим начальную СНН
    for i = 1:n
        j = 1;
        flag = 0;
        while j <= n && flag == 0
            if Cm(j, i) == 0 && sum(independent_zeros == j) == 0
                independent_zeros(i) = j;
                flag = 1;
            end
            j = j + 1;
        end
    end
     
    if DEBUG ~= 0
        print_Cm(Cm, independent_zeros);
    end
   
    % Выделенные столбцы
    marked_columns = zeros(1, n);
    
    % Выделяем столбцы, содержащие независимые нули
    for i = 1:n
        if independent_zeros(i) > 0
            marked_columns(i) = 1;
        end
    end
    
    % Выделенные строки
    marked_strings = zeros(1, n);
        
    % Координаты штрихованных нулей
    marked_zeros = zeros(1, n);    
    
    % Цикл до тех пор, пока решение не будет оптимальным
    while sum(independent_zeros == 0) ~= 0
        
        % Строка обнаруженного невыделенного нуля
        new_zero_string = 0;
        
        % Отмечаем невыделенный нуль штрихом
        i = 1;
        flag = 0;
        while i <= n && flag == 0
            if marked_columns(i) == 0
                j = 1;
                while j <= n && flag == 0
                    if Cm(j, i) == 0 && marked_strings(j) == 0
                        new_zero_string = j;
                        marked_zeros(i) = j;
                        flag = 1;
                    end
                    j = j + 1;
                end
            end
            i = i + 1;
        end
        
        % Обнаружили невыделенный нуль
        if flag == 1
            
            % Проверяем, что в строке обнаруженного нуля нет 0*
            if sum(independent_zeros == new_zero_string) == 0
                
                % Строим L-цепочку
                l_columns = find(marked_zeros ~= 0);
                l_chain = zeros(size(l_columns, 2) * 2 - 1, 2);
                l_chain(1, :) = [marked_zeros(l_columns(1)) l_columns(1)];
                for i = 2:size(l_columns, 2)
                    l_chain(i * 2 - 2, :) = [independent_zeros(l_columns(i - 1)) l_columns(i - 1)];
                    l_chain(i * 2 - 1, :) = [marked_zeros(l_columns(i)) l_columns(i)];
                end
                        
                % Удаляем штрихи и отметки строк и столбцов
                marked_zeros = zeros(1, n);
                marked_strings = zeros(1, n);
                marked_columns = zeros(1, n);
                
                % Формируем новую СНН
                for i = 1:size(l_chain, 1)
                    if mod(i, 2) ~= 0
                        independent_zeros(l_chain(i, 2)) = l_chain(i, 1);
                    end
                end
                
                % Заново выделяем столбцы
                for i = 1:n
                    if independent_zeros(i) > 0
                        marked_columns(i) = 1;
                    end
                end
                
                if DEBUG ~= 0
                    print_Cm(Cm, independent_zeros);
                end
            else
                % Переносим отметку со столбца на строку
                marked_strings(new_zero_string) = 1;
                marked_columns(independent_zeros == new_zero_string) = 0;
            end
        else
            % Невыделенных нулей необнаружено, создаем новые нули
            minimal = Inf();
            for i = 1:n
                for j = 1:n
                    if marked_strings(i) == 0 && marked_columns(j) == 0 && Cm(i, j) < minimal
                        minimal = Cm(i, j);
                    end
                end
            end
            for i = 1:n
                for j = 1:n
                    if marked_strings(i) == 1
                        Cm(i, j) = Cm(i, j) + minimal;
                    end
                    if marked_columns(j) == 0
                        Cm(i, j) = Cm(i, j) - minimal;
                    end
                end
            end
        end
    end
        
    % Печать матрицы назначений
    for i = 1:n
        for j = 1:n
            if independent_zeros(j) == i
                fprintf("    1  ");
            else
                fprintf("    0  ");
            end
        end
        fprintf("\n");
    end
    fprintf("\n");
    
    % Вывод итогового значения
    s = 0;
    for i = 1:n
        s = s + C(independent_zeros(i), i);
    end
     
    if MAXIMIZE ~= 0
        fprintf("    Максимальная эффективность: %d\n\n", s);
    else
        fprintf("    Минимальные затраты: %d\n\n", s);
    end
end

% Печать матрицы стоимостей
function print_Cm(Cm, independent_zeros)
    n = size(Cm, 1);
    for i = 1:n
        for j = 1:n
            if independent_zeros(j) == i
                fprintf("  %3d* ", Cm(i, j));
            else
                fprintf("  %3d  ", Cm(i, j));
            end
        end
        fprintf("\n");
    end
    fprintf("\n");
end