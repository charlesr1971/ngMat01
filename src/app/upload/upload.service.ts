
import { Injectable } from '@angular/core';
import { HttpClient, HttpRequest, HttpEventType, HttpResponse, HttpHeaders } from '@angular/common/http';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs/Observable';

import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

const url = environment.ajax_dir + '/upload-image.cfm';

@Injectable()
export class UploadService {

  imagePath: string;
  name: string;
  title: string;
  description: string;

  subscriptionImageUrl: Subject<any> = new Subject<any>();

  constructor(private http: HttpClient, 
    private httpService: HttpService) {
      this.httpService.subjectImagePath.subscribe( (data: any) => {
        console.log('upload.service: data: ',data);
        this.imagePath = data['imagePath'];
        this.name = data['name'];
        this.title = data['title'];
        this.description = data['description'];
      });
    }

  public upload(files: Set<File>): {[key:string]:Observable<number>} {
    // this will be the our resulting map
    const status = {};

    files.forEach(file => {
      // create a new multipart-form for every file
      const formData: FormData = new FormData();
      formData.append('file', file, file.name);

      console.log('upload: file ',file);

      let fileExtension: any = file.type.split("/");
      fileExtension = Array.isArray(fileExtension) ? fileExtension[fileExtension.length-1] : "";

      const httpOptions = {
        reportProgress: true,
        headers: new HttpHeaders({
          'Image-path':  this.imagePath,
          'Name': this.name,
          'Title': this.title,
          'Description': this.description,
          'File-Extension': fileExtension
        })
      };

      // create a http-post request and pass the form
      // tell it to report the upload progress
      /* const req = new HttpRequest('POST', url, formData, {
        reportProgress: true
      }); */

      const req = new HttpRequest('POST', url, file, httpOptions);

      // create a new progress-subject for every file
      const progress = new Subject<number>();

      // send the http-request and subscribe for progress-updates
      this.http.request(req).subscribe(event => {

        if (event.type === HttpEventType.UploadProgress) {

          // calculate the progress percentage
          const percentDone = Math.round(100 * event.loaded / event.total);

          // pass the percentage into the progress-stream
          progress.next(percentDone);
        } else if (event instanceof HttpResponse) {

          // Close the progress-stream if we get an answer form the API
          // The upload is complete
          console.log('upload: event ',event);
          if('imagePath' in event.body && event.body['imagePath'] != '') {
            this.subscriptionImageUrl.next(event.body['imagePath']);
          }

          progress.complete();

        }
        
      });

      // Save every progress-observable in a map of all observables
      status[file.name] = {
        progress: progress.asObservable()
      };
    });

    // return the map of progress.observables
    return status;
  }
}
