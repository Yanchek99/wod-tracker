# Conditional Current Password for Profile Updates

## Goal

Allow users to update profile details without entering their current password, while requiring the current password for email or password changes.

## Design

Override Devise's registration update behavior in a project registration controller. If the submitted email differs from the persisted email or a new password is present, use Devise's `update_with_password`; otherwise use `update_without_password` while excluding password-related parameters. Route Devise registrations through this controller.

The profile form will make the current-password input optional and explain that it is required only when changing email or password. Server-side behavior remains authoritative; no client-side JavaScript is required.

## Testing

Add controller/request coverage for profile-only updates without a current password, sensitive updates without a current password, sensitive updates with the correct password, and the edit form's optional current-password field.

## Scope

No changes to password-reset flows, account deletion, or unrelated profile validation.
