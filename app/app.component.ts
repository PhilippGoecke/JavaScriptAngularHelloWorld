import { Component, VERSION } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  name: string;
  angularVersion = VERSION.full;

  constructor() {
    const params = new URLSearchParams(window.location.search);
    this.name = params.get('name') || 'World';
  }
}
