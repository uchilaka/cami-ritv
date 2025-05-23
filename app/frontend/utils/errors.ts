export class InvalidAccountError extends Error {
  errorData: any

  constructor(message: string, errorData?: unknown) {
    super(message)
    this.name = 'InvalidAccountError'
    this.errorData = errorData
  }
}
export class AccountNotFoundError extends Error {}
export class AccountSuspendedError extends Error {}
export class AccountDeactivatedError extends Error {}
export class AccountPaymentDueError extends Error {}
export class AccountOverdueError extends Error {}
export class MissingRequiredContextError extends Error {}
