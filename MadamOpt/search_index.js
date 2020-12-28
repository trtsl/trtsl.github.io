var documenterSearchIndex = {"docs":
[{"location":"#MadamOpt.jl","page":"Home","title":"MadamOpt.jl","text":"","category":"section"},{"location":"#Summary","page":"Home","title":"Summary","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is a teseting ground for some extensions related to Adam (Adaptive Moment Estimation). For a summary description see the readme.","category":"page"},{"location":"#API-reference","page":"Home","title":"API reference","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Madam\nstep!\nupdate!\nstep_ols!\nupdate_ols!\ncurrent","category":"page"},{"location":"#MadamOpt.Madam","page":"Home","title":"MadamOpt.Madam","text":"Madam{T}(\n    theta\n    ; alpha     = 0.01\n    , beta1     = 0.9\n    , beta2     = 0.999\n    , beta3     = 0.9\n    , eps       = 1e-8\n    , max_temp  = 0.0\n    , max_steps = nothing\n    , dx        = 1e-8\n)\n\nArguments\n\ntheta::T: the initial parameters (i.e. staring point).\nalpha::Float64: learning-rate / step-size.\nbeta1::Float64: controls the exponential decay rate for the 1st moment.\nbeta2::Float64: controls the exponential decay rate for the 2nd moment.\nbeta3::Float64: in gradient-free usage, beta3 determines over what period a gradient approximation that was not recently sampled should decay\neps::Float64: small-constant for numerical stability.\nmax_temp::Float64: starting temperature representing the search space perturbations used to estimate the gradient; the perturbations will approach zero when max_steps is reached; setting this parameter can help with non-convex problems\nmax_steps::Union{Integer, Nothing}: if an Integer is set, the algorithm will estimate the gradient using a larger region around the current estimate to allow optimizing non-convex functions\ndx::Float64: the steady state perturbations used to estimate the gradient after max_steps have been taken\n\nConstruct the Madam optimizer.\n\n\n\n\n\n","category":"type"},{"location":"#MadamOpt.step!","page":"Home","title":"MadamOpt.step!","text":"step!(\n    adam\n    , grad\n    ; l1_penalty    = nothing\n    , l2_penalty    = nothing\n    , weight_decay  = nothing\n)\n\nAdvances the algorithm by one step based on the current gradient, but does not update theta estimates.  This method is included for interfaces such as those of FluxML which require that only the step size is returned.\n\nArguments\n\nadam::Madam{T}\ngrad::T: the gradient for the next set of observations (i.e mini-batch)\nl1_penalty::Union{Nothing, Float64}: penalty for L1 regularization (implemented via the proximal operator)\nl2_penalty::Union{Nothing, Float64}: penalty for L2 regularization\nweight_decay::Union{Nothing, Float64}: weight decay regularization\n\n\n\n\n\nstep!(adam, loss; grad_samples=max(1,length(adam.theta) >> 4), kwargs...)\n\nAdvances the algorithm by one step based on a loss function.\n\nArguments\n\nadam::Madam{T}\nloss::Function: objective or loss function (e.g. mini-batch loss)\ngrad_samples::Integer: The number of samples taken from the loss function to estimate the gradient.  This value must be in the range 0 <= grad_samples <= length(parameters).\nkwargs....: l1_penalty, l2_penalty, and weight_decay penalties described above\n\n\n\n\n\n","category":"function"},{"location":"#MadamOpt.update!","page":"Home","title":"MadamOpt.update!","text":"update!(adam, args...; kwargs...)\n\nCalls step! and then also updates the parameter estimates theta.\n\n\n\n\n\n","category":"function"},{"location":"#MadamOpt.step_ols!","page":"Home","title":"MadamOpt.step_ols!","text":"step_ols!(adam, A, b; kwargs...)\n\nFor linear models of the form Ax = b, this is a convenience method that calculates the gradient given A and b.\n\nArguments\n\nadam::Madam\nA::AbstractArray{Float64, Union{1,2}}: Design / independent variables.\nA::Union{AbstractArray{Float64, 1}, Float64}: Response / dependent variables.\nkwargs....: same keyword arguments as for step!.\n\n\n\n\n\n","category":"function"},{"location":"#MadamOpt.update_ols!","page":"Home","title":"MadamOpt.update_ols!","text":"update_ols!(adam, args...; kwargs...)\n\nCalls step_ols! and then also updates the parameter estimates theta.\n\n\n\n\n\n","category":"function"},{"location":"#MadamOpt.current","page":"Home","title":"MadamOpt.current","text":"current(adam::Madam)\n\nRetrieves a reference to the current parameter estimates (i.e. theta in constructor Madam).\n\n\n\n\n\n","category":"function"}]
}
