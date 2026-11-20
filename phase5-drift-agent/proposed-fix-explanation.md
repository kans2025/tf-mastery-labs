# Proposed Drift Fix

## What drifted

`module.vm.google_compute_firewall.allow_ssh` has `disabled = true` in the
observed state, while the Terraform configuration leaves the firewall enabled
by default. The firewall allows TCP/22 only from `35.235.240.0/20`.

## Evidence

- The drift entry records `disabled` changing from `false` to `true`.
- Commit `038e200` initially allowed SSH from `0.0.0.0/0`; commit `8b33b4f`
  narrowed the source range to `35.235.240.0/20`, consistent with allowing SSH
  through Google IAP rather than from the public internet.
- The OPA policy rejects SSH from `0.0.0.0/0`; it does not require the firewall
  to be disabled.
- The `changed-by=console` label is on the VM, not the drifted firewall, so it
  does not establish why this firewall was disabled.

## Classification

Accidental is the best-supported classification, though the available evidence
cannot rule out an intentional emergency disable. Disabling the firewall
prevents the IAP-limited SSH access configured by the code, and there is no
corresponding Terraform change or firewall-specific change attribution.

## Proposed fix

No Terraform code change is needed: the configuration already leaves
`allow_ssh` enabled, and merging this PR reconciles the drift through the
pipeline's apply job. If an authorized operator confirms the firewall was
intentionally disabled, do not re-enable it; record that decision and represent
the desired disabled state in Terraform. Making `disabled = false` explicit is
an optional follow-up.

## What merging this PR will do

This PR changes no Terraform code, but merging it to `main` triggers the
pipeline's apply job. The job plans against the current code and re-enables
`allow_ssh` (`disabled = true` -> `false`): 0 added, 1 changed, 0 destroyed.
Therefore, merging this PR changes the cloud by applying that plan.
