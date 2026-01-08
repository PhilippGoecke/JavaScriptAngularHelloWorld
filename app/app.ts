import { Component, VERSION } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet]
  templateUrl: './app.html',
  styleUrl: './app.css'
})

export class App {
  name: string;
  angularVersion = VERSION.full;

  constructor() {
    const params = new URLSearchParams(window.location.search);
    this.name = params.get('name') || 'World';
  }
}
