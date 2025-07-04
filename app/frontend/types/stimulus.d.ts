declare module '@hotwired/stimulus' {
  import { Controller as BaseController } from 'stimulus';

  export class Controller extends BaseController {
    /**
     * The Stimulus application instance
     */
    static application: Application;

    /**
     * The element this controller is bound to
     */
    readonly element: HTMLElement;

    /**
     * The controller's identifier
     */
    readonly identifier: string;

    /**
     * The controller's targets
     */
    static readonly targets: string[];

    /**
     * The controller's values
     */
    static readonly values: { [key: string]: { type: any; default?: any } };

    /**
     * Called when the controller is connected to the DOM
     */
    connect(): void;

    /**
     * Called when the controller is disconnected from the DOM
     */
    disconnect(): void;

    /**
     * Called when a target is added
     * @param target The target element
     * @param name The target name
     */
    [targetConnected](target: Element, name: string): void;

    /**
     * Called when a target is removed
     * @param target The target element
     * @param name The target name
     */
    [targetDisconnected](target: Element, name: string): void;
  }

  export class Application {
    /**
     * Register a controller with the application
     * @param name The controller name
     * @param controller The controller class
     */
    register(name: string, controller: typeof Controller): void;

    /**
     * Start the application
     */
    start(): void;

    /**
     * Stop the application
     */
    stop(): void;
  }

  /**
   * Create a new Stimulus application
   */
  export function start(...args: any[]): Application;

  /**
   * The default Stimulus application instance
   */
  export const application: Application;
}
