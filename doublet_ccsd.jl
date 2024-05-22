using SpinAdaptedSecondQuantization

include("doublet_cc_definitions.jl")
include("fixed_tensor_manipulations.jl")

# Define translator for nice prints
trans = translate(OccupiedOrbital => 1:2:20, VirtualOrbital => 2:2:20)

# Get operators (T1 transformed)
H = get_H()
P = get_doublet_P()
P = get_bch_operator(1, P, 4) |> SpinAdaptedSecondQuantization.simplify

T2 = Tn(2)
@show T2

# Define projection manifolds <χ| = <μ| exp(-T2) P
# NOTE: we use annihilation and creation operators and not the singlet E operators.
# This is because we want to count the excitation order
@time μ_0 = get_projection_manifold(0, P, T2, 1) |> SpinAdaptedSecondQuantization.simplify
@time μ_1 = get_projection_manifold(1, P, T2, 1) |> SpinAdaptedSecondQuantization.simplify
@time μ_2 = get_projection_manifold(2, P, T2, 2) |> SpinAdaptedSecondQuantization.simplify

μ_0 = put_trig_in_scalar(μ_0) |> SpinAdaptedSecondQuantization.simplify_heavy
μ_1 = put_trig_in_scalar(μ_1) |> SpinAdaptedSecondQuantization.simplify_heavy
μ_2 = put_trig_in_scalar(μ_2) |> SpinAdaptedSecondQuantization.simplify_heavy

# Projections from reference
μ_0_0 = get_ex_of_order(μ_0, 0)
μ_0_1 = get_ex_of_order(μ_0, 1)
μ_0_2 = get_ex_of_order(μ_0, 2)
μ_0_3 = get_ex_of_order(μ_0, 3) # This should be zero for the doublet P

# @show (μ_0_0, trans)
# @show (μ_0_1, trans)
# @show (μ_0_2, trans)

# # Projections from singles manifold
# μ_1_0 = get_ex_of_order(μ_1, 0)
# μ_1_1 = get_ex_of_order(μ_1, 1)
# μ_1_2 = get_ex_of_order(μ_1, 2)
# μ_1_3 = get_ex_of_order(μ_1, 3)
# μ_1_4 = get_ex_of_order(μ_1, 4) # This should be zero for the doublet P

# # @show (μ_1_0, trans)
# # @show (μ_1_1, trans)
# # @show (μ_1_2, trans)
# # @show (μ_1_3, trans)

# # Projections from doubles manifold
# μ_2_0 = get_ex_of_order(μ_2, 0)
# μ_2_1 = get_ex_of_order(μ_2, 1)
# μ_2_2 = get_ex_of_order(μ_2, 2)
# μ_2_3 = get_ex_of_order(μ_2, 3)
# μ_2_4 = get_ex_of_order(μ_2, 4)
# μ_2_5 = get_ex_of_order(μ_2, 5) # This should be zero for the doublet P

# @show (μ_2_0, trans)
# @show (μ_2_1, trans)
# @show (μ_2_2, trans)
# @show (μ_2_3, trans)
# @show (μ_2_4, trans)

# #
# # Evaluate equation < χ| H exp(T2) |ν >:

# # Quadruples contribution to Ω_μ2 (highest scaling equations for the doublet P):

# # Evaluation of excitation order: <μ_2_4| H -> 4 ± 2 -> [2, 6]  in exp(T2) we need T2^3 ( = 6)
# # could have skipped first term in exp(T2) = 1 + T2 + 1/2 T2^2 + 1/6 T2^3, because it
# # is zero in any case. We include it, because it is not expensive in this case.
# #
# @time Ω_μ2_2 = project_equation_on_bra(μ_2_2, H, 0, T2, 2) |> SpinAdaptedSecondQuantization.simplify

# # Identify L and u tensors to simplify expression and put trig into scalar
# # (this can be expensive and mostly important for code generation)
# @time Ω_μ2_2 = look_for_tensor_replacements_smart(Ω_μ2_2, make_exchange_transformer("t", "u")) |> SpinAdaptedSecondQuantization.simplify
# @time Ω_μ2_2 = look_for_tensor_replacements_smart(Ω_μ2_2, make_exchange_transformer("g", "L")) |> SpinAdaptedSecondQuantization.simplify

# @time Ω_μ2_2 = put_trig_and_fixed_tensor_in_scalar(Ω_μ2_2) |> SpinAdaptedSecondQuantization.simplify

# # Prepare for code generation
# @time Ω_μ2_2_s, Ω_μ2_2_ss, Ω_μ2_2_ns = desymmetrize(Ω_μ2_2, make_permutation_mappings([(3,4),(5, 6)]))

# @time Ω_μ2_2_s = change_summation_indices(Ω_μ2_2_s)
# @time Ω_μ2_2_s = rename_tensors(Ω_μ2_2_s)
# @show (Ω_μ2_2_s, trans)