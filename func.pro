function func, x, param
    ;; power law: param[0] * x^param[1]
    
    return, [ [param[0]*(x^param[1])],  $
              [x^param[1]],  $
              [param[0] * alog(x) * x^param[1]] $
            ]
end

