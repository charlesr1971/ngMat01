import { uuid } from './../util/uuid';

export class Image {

    id: string;
    category: string;
    src: string;
    author: string;
    title: string;
    description: string;

    constructor(obj?: any) {
        this.id = obj && obj.id || uuid();
        this.category = obj && obj.category || null;
        this.src = obj && obj.src || null;
        this.author = obj && obj.author || null;
        this.title = obj && obj.title || null;
        this.description = obj && obj.description || null;
    }

}